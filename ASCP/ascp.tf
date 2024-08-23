# https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html
# Policy
# {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret"
#           ],
#         "Resource": "SecretARN"
#       }
#     ]
#   }

# Role 
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "Federated": "arn:aws:iam::614637516007:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/C8C6FEDB919E7EC2C625B5C74773C2CA"
#             },
#             "Action": "sts:AssumeRoleWithWebIdentity",
#             "Condition": {
#                 "StringEquals": {
#                     "oidc.eks.us-east-1.amazonaws.com/id/C8C6FEDB919E7EC2C625B5C74773C2CA:aud": "sts.amazonaws.com",
#                     "oidc.eks.us-east-1.amazonaws.com/id/C8C6FEDB919E7EC2C625B5C74773C2CA:sub": "system:serviceaccount:default:nginx-deployment-sa"
#                 }
#             }
#         }
#     ]
# }

# Service Account
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   annotations:
#     eks.amazonaws.com/role-arn: arn:aws:iam::614637516007:role/eksctl-final-project-eks-cluster-dev-addon-ia-Role1-CRy1h48pLO5f
#   labels:
#     app.kubernetes.io/managed-by: eksctl
#   name: nginx-deployment-sa
#   namespace: default

# Install and configure ASCP
# helm repo update
# helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
# helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver
# helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws
# helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws



# Example: Mount secrets by name or ARN
# The following example shows a SecretProviderClass that mounts three files in Amazon EKS:

# 1. A secret specified by full ARN.

# 2. A secret specified by name.

# 3. A specific version of a secret.

# apiVersion: secrets-store.csi.x-k8s.io/v1
# kind: SecretProviderClass
# metadata:
#   name: aws-secrets
# spec:
#   provider: aws
#   parameters:
#     objects: |
#         - objectName: "arn:aws:secretsmanager:us-east-2:111122223333:secret:MySecret2-d4e5f6"
#         - objectName: "MySecret3"
#           objectType: "secretsmanager"
#         - objectName: "MySecret4"
#           objectType: "secretsmanager"
#           objectVersionLabel: "AWSCURRENT"

        
