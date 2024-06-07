### EKS Cluster ###

resource "aws_eks_cluster" "fp_eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_iam_role.arn
  version  = var.k8_version #latest kubernetes version 1.30

  vpc_config {
    subnet_ids         = var.eks_pub_sub_ids
    security_group_ids = [aws_security_group.worker_node_sg.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

### EKS Cluster IAM Role ###

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
  name               = "fp-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_iam_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_iam_role.name
}

# ### EKS OIDC ### https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html

data "tls_certificate" "eks_tls" {
  url = aws_eks_cluster.fp_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "example" {
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
      variable = "${replace(aws_iam_openid_connect_provider.example.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.example.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "cni_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
  name               = "fp-eks-vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "cni_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cni_role.name
}

## EKS Add On ###

resource "aws_eks_addon" "cni" {
  depends_on               = [aws_iam_role.cni_role]
  cluster_name             = aws_eks_cluster.fp_eks_cluster.name
  addon_name               = "vpc-cni"
  service_account_role_arn = aws_iam_role.node_iam_role.arn
}

##https://davegallant.ca/blog/amazon-ebs-csi-driver-terraform/
# resource "aws_eks_addon" "ebs" {
#   cluster_name = aws_eks_cluster.fp_eks_cluster.name
#   addon_name   = "aws-ebs-csi-driver"
#   service_account_role_arn = aws_iam_role.node_iam_role.arn
# }

### EKS SG ###

resource "aws_security_group" "eks_cluster_sg" {
  name   = "eks-sg"
  vpc_id = var.vpc_id

  tags = {
    Name                                  = "eks-sg"
    "kubernetes.io/cluster/project-x-dev" = "owned"
    "aws:eks:cluster-name"                = var.eks_cluster_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id            = aws_security_group.eks_cluster_sg.id
  referenced_security_group_id = aws_security_group.eks_cluster_sg.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_traffic_ipv4" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id            = aws_security_group.eks_cluster_sg.id
  referenced_security_group_id = aws_security_group.worker_node_sg.id
  ip_protocol                  = "-1"
}