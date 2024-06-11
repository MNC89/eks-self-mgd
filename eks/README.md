

./max-pods-calculator.sh --instance-type t3.medium --cni-version 1.16.0-eksbuild.1 
./max-pods-calculator.sh --instance-type t3.medium --cni-version 1.16.0-eksbuild.1 --cni-prefix-delegation-enabled

`kubectl set env ds aws-node -n kube-system WARM_IP_TARGET=5`
`kubectl set env ds aws-node -n kube-system MINIMUM_IP_TARGET=2`
