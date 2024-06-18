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

1. Clone the repository and create a "dev" environment in the GitHub repository.
  * Save the arn of the created role as "IAM_ROLE" GitHub environment variable
2. Create aws keypair to ssh into worker nodes and save it securely
  * `aws ec2 create-key-pair --key-name fp-eks-worker-node-key-pair`
3. Create a new branch and adjust the kubernetes_resources/aws_auth files to your needs 
4. Git Push to deploy EKS Cluster, VPC and attached applications
5. Configure VPC CNI add on
  a. Login to the kubernetes cluster
  b. Set WARM_IP_TARGET and MINIMUM_IP_TARGET with your values
    * More information can be found [here](https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/prefix-and-ip-target.md)
    * `kubectl set env ds aws-node -n kube-system WARM_IP_TARGET=5`
    * `kubectl set env ds aws-node -n kube-system MINIMUM_IP_TARGET=2`
  c. (Optional) Adjust the --max-pods flag in the bootstrap script of the launch template 
    * More information can be found [here](https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html)
    * Default set to 110 (maximum for t3.medium)

## Acknowledgments

* Ingress-nginx controller installation guide: https://kubernetes.github.io/ingress-nginx/deploy/#aws
* EKS worker node provisioning: https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/
* Increasing available IP addresses on worker nodes: https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
* VPC-CNI Prefix and IP targets: https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/prefix-and-ip-target.md
* EKS Troubleshooting: https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html#not-ready
* EKS Security Groups: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
* Local-exec Provisioners: https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec

## Challenges

* Lack of official Terraform and AWS documentation: Terraform does not have a module for a self managed node group and the AWS documentation only gives instructions on how to create one with eksctl or through the AWS Management Console. Finding documentation turned out to be challenging because of how involved it is to create a self managed node group. The upside, however is having very granular control.
* Worker node keypair: I was initally going to create a keypair dynamically each time the workflow was run, but I realized that doing so would store a copy in the tf.state file. After researching many methods, I decided that the most secure was to have the user create one given the provided aws cli command and store it locally. 
* Worker node AMI: I couldn't figure out which AMI to go with for the worker nodes because there were too many options. With a little research, I was able to find the EKS optimized nodes and pull the lastest AMI dynamically from ssm for the launch template.
* VPC CNI: While I understood the basic concept of this addon, I had to do a lot of research to figure out how to set it up properly. Figuring out how to find the maximum pods that an instance can support and trying to understand what WARM_IP_TARGET and MINIMUM_IP_TARGET were definitely a challenge.
* EBS CSI: This was a very tricky addon to make work with the GHA Workflow File. It would perpetually stay in a degraded state and cause the workflow to fail. In order to make it work, I had to add a terraform_data resource with a provisioner block to apply the aws-auth file. This allowed the worker nodes to join the cluster and let the EBS CSI pods deploy on them. 
