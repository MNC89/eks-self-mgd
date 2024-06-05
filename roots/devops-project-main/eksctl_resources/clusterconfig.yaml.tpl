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
    iam:
        attachPolicyARNs:
          - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
          - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
          - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
          - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
    ssh:
        allow: true
        publicKeyName: fp-eks-worker-node-key-pair
              