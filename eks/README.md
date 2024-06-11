## Getting Started

### Prerequisites

The VPC is deployed alongside the EKS cluster and apps in this repository using the GitHub Actions workflow located in the .github directory. 

* AWS account with proper access
* Create a GitHubActionsTerraformIAMrole with AdministratorAccess
  * Limit permissions to your needs

### Installation

* Clone the repository and create a "dev" environment in the GitHub repository.
  * Save the arn of the created role as "IAM_ROLE" GitHub environment variable

./max-pods-calculator.sh --instance-type t3.medium --cni-version 1.16.0-eksbuild.1 
./max-pods-calculator.sh --instance-type t3.medium --cni-version 1.16.0-eksbuild.1 --cni-prefix-delegation-enabled

`kubectl set env ds aws-node -n kube-system WARM_IP_TARGET=5`
`kubectl set env ds aws-node -n kube-system MINIMUM_IP_TARGET=2`
