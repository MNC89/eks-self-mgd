## About The Project

This EKS cluster is entirely self managed and created on terraform. It is designed to be deployed along side the VPC in this repo to work properly. 

### The key features are:
* Cluster runs on Kubernetes version 1.29 by default
* Self managed worker nodes
  * Deployed by an Auto Scaling Group on t3.medium and similar instance types
  * 20% on-demand and 80% spot instances for cost savings
  * Deployed on multiple AZs for greater availability
  * Launch template uses latest optimised EKS AMI from SSM
* aws-auth config file for access to the kubernetes cluster
* VPC CNI addon (Virtual Private Cloud Container Network Interface)
  * Allows for up to 110 pods to be deployed on each t3.medium node
* EBS CSI addon (Elastic Block Store Container Storage Interface)
  * Creates EBS volumes for Kubernetes Persistent Volumes and Ephemeral Volumes

## Getting Started

### Prerequisites

The EKS cluster is deployed alongside the VPC and apps in this repository using the GitHub Actions workflow located in the .github directory. 

* AWS account with proper access
* AWS CLI
* Create a GitHubActionsTerraformIAMrole with AdministratorAccess
  * Limit permissions to your needs

### Installation

* Clone the repository and create a "dev" environment in the GitHub repository.
  * Save the arn of the created role as "IAM_ROLE" GitHub environment variable
* Create aws keypair to ssh into worker nodes and save it securely
  `aws ec2 create-key-pair --key-name fp-eks-worker-node-key-pair`
* Create a new branch and push to deploy EKS Cluster, VPC and attached applications
* Configure VPC CNI add on
  * Login to the kubernetes cluster
  * Set WARM_IP_TARGET and MINIMUM_IP_TARGET with your values
    * More information can be found here: https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/prefix-and-ip-target.md
  `kubectl set env ds aws-node -n kube-system WARM_IP_TARGET=5`
  `kubectl set env ds aws-node -n kube-system MINIMUM_IP_TARGET=2`
  * (Optional) Adjust the --max-pods flag in the launch template 
    * More information can be found here: https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
    * Default set to 110 (maximum for t3.medium)

## Acknowledgments

* Ingress-nginx controller installation guide: https://kubernetes.github.io/ingress-nginx/deploy/#aws
* EKS worker node provisioning: https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/
* Increasing available IP addresses on worker nodes: https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
* VPC-CNI Prefix and IP targets: https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/prefix-and-ip-target.md
* EKS Troubleshooting: https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html#not-ready