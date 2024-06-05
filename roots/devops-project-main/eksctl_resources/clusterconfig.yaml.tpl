apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: final-project-eks-cluster-${ENVIRONMENT_STAGE}
  region: us-east-1
  version: '1.29'
    
iam:
  withOIDC: true

vpc:
  id: ${VPC_ID}
  subnets:
    public:
      us-east-1a: 
        id: ${PUBLIC_ID_1} 
      us-east-1b:
        id: ${PUBLIC_ID_2} 
      us-east-1c: 
        id: ${PUBLIC_ID_3} 
  securityGroup: ${EKS_SG}
      
nodeGroups:
  - name: final-project-eks-nodegroup
    desiredCapacity: 3
    minSize: 1
    maxSize: 5
    instancesDistribution:
      instanceTypes: ["t3.medium", "t3a.medium", "t2.medium"] # At least one instance type should be specified
      onDemandBaseCapacity: 0
      onDemandPercentageAboveBaseCapacity: 20
      spotInstancePools: 2
    ami: auto-ssm
    amiFamily: AmazonLinux2
    overrideBootstrapCommand: |
      #!/bin/bash
      set -o xtrace

      CLUSTER_NAME="final-project-eks-cluster-dev"
      REGION="us-east-1"

      if ! command -v aws &>/dev/null; then
          echo "AWS CLI is not installed. Installing..."
          curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          unzip awscliv2.zip
          sudo ./aws/install
      fi

      aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

      /etc/eks/bootstrap.sh $CLUSTER_NAME \
                       --kubelet-extra-args "--node-labels=node-type=worker" \
                       --apiserver-endpoint="<your-eks-cluster-endpoint>" \
                       --b64-cluster-ca="<your-eks-cluster-cert-authority-data>" \
                       --dns-cluster-ip="<your-eks-cluster-dns-ip>"


      /opt/aws/bin/cfn-signal --exit-code $? \
                        --stack  <your-stack-name> \
                        --resource <your-resource-name>  \
                        --region $REGION

    iam:
        attachPolicyARNs:
          - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
          - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
          - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
          - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
    ssh:
        allow: true
        publicKeyName: fp-eks-worker-node-key-pair
              