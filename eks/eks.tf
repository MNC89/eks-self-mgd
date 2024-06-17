## EKS Cluster ###

resource "aws_eks_cluster" "fp_eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_iam_role.arn
  version  = var.k8_version #latest kubernetes version 1.30

  vpc_config {
    subnet_ids         = var.eks_pub_sub_ids
    security_group_ids = [aws_security_group.worker_node_sg.id, aws_security_group.eks_cluster_sg.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_policy,
  ]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION"

    environment = {
      CLUSTER_NAME = var.eks_cluster_name
      REGION       = data.aws_region.current.name
    }
  }
}

## Data block to pull current region name used in eks provisioner ###

data "aws_region" "current" {}

## EKS Cluster IAM Role ###

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_iam_role" {
  name               = var.eks_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  for_each   = var.eks_policy
  policy_arn = each.value
  role       = aws_iam_role.eks_iam_role.name
}

## EKS OIDC for Add Ons ### https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html

data "tls_certificate" "eks_tls" {
  url = aws_eks_cluster.fp_eks_cluster.identity[0].oidc[0].issuer
}

## VPC CNI ###

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.fp_eks_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

## EBS CSI ###

data "aws_iam_policy_document" "ebs_csi_driver_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.oidc_provider.url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.oidc_provider.url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

  }
}

# EKS Add Ons ### #v1.18.2-eksbuild.1

resource "aws_eks_addon" "cni" {
  depends_on                  = [aws_iam_role.cni_role]
  cluster_name                = aws_eks_cluster.fp_eks_cluster.name
  addon_name                  = var.vpc_cni_addon_name
  addon_version               = var.vpc_cni_version
  resolve_conflicts_on_update = var.vpc_cni_update_resolve
  service_account_role_arn    = aws_iam_role.cni_role.arn
}

resource "aws_iam_role" "cni_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
  name               = var.vpc_cni_role_name
}

resource "aws_iam_role_policy_attachment" "Addon_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cni_role.name
}

#https://davegallant.ca/blog/amazon-ebs-csi-driver-terraform/
resource "aws_eks_addon" "ebs" {
  depends_on               = [aws_iam_role.ebs_csi_role, aws_autoscaling_group.fp_asg]
  cluster_name             = aws_eks_cluster.fp_eks_cluster.name
  addon_name               = var.ebs_csi_addon_name
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn
}

resource "aws_iam_role" "ebs_csi_role" {
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_role.json
  name               = var.ebs_csi_role_name
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role.name
}

## EKS SG ###

resource "aws_security_group" "eks_cluster_sg" {
  name   = var.eks_sg_name
  vpc_id = var.vpc_id

  tags = {
    Name                                            = var.eks_sg_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "aws:eks:cluster-name"                          = var.eks_cluster_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_self" {
  security_group_id            = aws_security_group.eks_cluster_sg.id
  referenced_security_group_id = aws_security_group.eks_cluster_sg.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_eks_made" {
  security_group_id            = aws_security_group.eks_cluster_sg.id
  referenced_security_group_id = aws_eks_cluster.fp_eks_cluster.vpc_config[0].cluster_security_group_id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_traffic_ipv4" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
