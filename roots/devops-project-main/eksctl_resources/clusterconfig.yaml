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
    amiFamily: Ubuntu2204
    ami: ami-0e001c9271cf7f3b9  # Ubuntu 22.04 (x86)
    overrideBootstrapCommand: |
      #!/bin/bash
      
      export CLUSTER_NAME="final-project-eks-cluster-${ENVIRONMENT_STAGE}"
      export NODE_LABELS="purpose=final-project"
      export B64_CLUSTER_CA="$(aws eks describe-cluster --name final-project-eks-cluster-${ENVIRONMENT_STAGE} --region us-east-1 --query 'cluster.certificateAuthority.data' --output text)"
      export API_SERVER_URL="$(aws eks describe-cluster --name final-project-eks-cluster-${ENVIRONMENT_STAGE} --region us-east-1 --query 'cluster.endpoint' --output text)"
      export CLUSTER_DNS="10.100.0.10"
      export MAX_PODS="110"

      source /var/lib/cloud/scripts/eksctl/bootstrap.helper.sh

      /etc/eks/bootstrap.sh $CLUSTER_NAME \
        --kubelet-extra-args "${KUBELET_EXTRA_ARGS}" \
        --apiserver-endpoint "$API_SERVER_URL" \
        --b64-cluster-ca "$B64_CLUSTER_CA" \
        --dns-cluster-ip "$CLUSTER_DNS"

      apt-get update -y && apt-get upgrade -y
      apt-get install -y jq awscli
    iam:
        attachPolicyARNs:
          - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
          - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
          - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
          - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
    ssh:
        allow: true
        publicKeyName: fp-eks-worker-node-key-pair
              