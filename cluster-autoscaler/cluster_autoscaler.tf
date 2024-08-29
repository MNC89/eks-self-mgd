# IAM role for the main cluster
# resource "aws_iam_role" "AmazonEKSMainClusterAutoscalerRole" {
#   name = "AmazonEKSMainClusterAutoscalerRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = "arn:aws:iam::340924313311:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${var.eks_cluster_id}"
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             "oidc.eks.us-east-1.amazonaws.com/id/${var.eks_cluster_id}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
#           }
#         }
#       }
#     ]
#   })
# }

# IAM policy for the roles
resource "aws_iam_policy" "AmazonEKSClusterAutoscalerPolicy" {
  name        = "AmazonEKSClusterAutoscalerPolicy"
  description = "Policy for Amazon EKS Cluster Autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

# Attach autoscaler policy to the roles
# resource "aws_iam_policy_attachment" "AmazonEKSClusterAutoscalerAttachment" {
#   name       = "AmazonEKSClusterAutoscalerAttachment"
#   roles      = [aws_iam_role.AmazonEKSMainClusterAutoscalerRole.name]
#   policy_arn = aws_iam_policy.AmazonEKSClusterAutoscalerPolicy.arn
# }