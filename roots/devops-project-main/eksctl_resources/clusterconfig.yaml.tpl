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

      aws eks --region us-east-1 update-kubeconfig --name final-project-eks-cluster-dev

      /etc/eks/bootstrap.sh final-project-eks-cluster-dev \
                       --kubelet-extra-args "--node-labels=node-type=worker" \
                       --apiserver-endpoint="https://A158A3673297D77F0690675D34C2BA25.gr7.us-east-1.eks.amazonaws.com" \
                       --b64-cluster-ca="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUEFuckxrTVFTMWt3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBMk1EVXhOak15TkRSYUZ3MHpOREEyTURNeE5qTTNORFJhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURDUXdIc0VsanNjbS9WTnB1eTdUM0lXTDk5Mk90c2xaeXlCVDdVZERDam5RMlY4L1htUTRQRnp1NTYKTEozYzNnMGdRSmlMZkZFbFJPellWRjRxRHVWdFFJdVVOL29oS2ZQY3BVaTlCTXM1MGRxOUJxTmUra0ZqbXFYWApKR2JpTS9MMjE5NUxVOVBoNi9QR3dEMHpiTGs3MnRWQy8wZDVvRXZKdFQ5MnJGSmo3MGlGSTdSNHZEcDNUYURKCnRiVXpDckR6NVVscTlKV0lXbW5JT3JPcEdSMlVhR3A4dTdwaURDL0R3b0w1UWZZbHdmNWFtZDJHYitmY2w4TlEKOTQwamlvN3kzcTZmdnhOdHVhZzBrcWJOZVplMSt3VUxEb1pXUTMyL1dKd3prQnkxS3hUdXVaUzBnY2FhYnpsLwpmTmtjK1crandjSytldXgrZ1ZEczFGQWVGUUVMQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUTzJkS1pEWm5FZU1uclYrdGQzZXVTUFU2bW96QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQkVYMGNvcXVEbwpxYUdiOFNKcmxneHZHbUdwdnFKMDlYWFZ1dnJFdzZjblA1WWdTNU9NQytteityNTdQTEtJOXZoOGFOQlFiWVFYCmNhMXduczRiRXBUcFNjcmxseVRjRlErWm1Bb09mRUY1NjNTYmY1YjMrczhmU1ZKaUExclJadDVPeUQ4a3VqU0MKbzZSYy9YRlhxd3pxa05OU1lTQTdvTDVRa1NHamI2bXcwSkhVTFc0b3QvRGVoekpVWW9SWGNjdE9MeGJBZWlWOAphUi8zQVhJL2laRkNrMDdydm1Gem13c0ZkYWRqcWVQakllcmdQZzAxa2Y1dDhFSXpyck8rcTAvQzR1RHRScXo0CmVMYzltWVpaZ2xxaXpraHFSU0ZuQzRMaXY3aWNOZmUySW1OdEsvWkIxRktuc2MyU3VGVzg4bStUZXdyWWpsZ2kKSTYyeHVBRmJSdWNsCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K" \
                       --dns-cluster-ip="172.20.0.0/16"

      EXIT_CODE=$?

      echo "Bootstrap command exited with code: $EXIT_CODE"

      /opt/aws/bin/cfn-signal --exit-code $EXIT_CODE \
                        --stack  eksctl-final-project-eks-cluster-dev-nodegroup-final-project-eks-nodegroup \
                        --resource NodeGroup \
                        --region us-east-1
      
      exit $EXIT_CODE

    iam:
        attachPolicyARNs:
          - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
          - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
          - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
          - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
    ssh:
        allow: true
        publicKeyName: fp-eks-worker-node-key-pair
              