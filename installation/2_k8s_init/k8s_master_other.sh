# show debug info 
set -o xtrace
BASEDIR=/bms


# 安装 Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.
# https://artifacthub.io/packages/helm/metrics-server/metrics-server

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ 
helm upgrade --install metrics-server metrics-server/metrics-server --set args="{--kubelet-insecure-tls}"  
# kubectl top node 
# kubectl top pods


# 安装负载均衡器
# https://metallb.universe.tf/installation/
  
# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

  
kubectl  apply -f /bms/data/metallb_install/metallb-0.13.10/config/manifests/metallb-native.yaml
kubectl  apply -f /bms/data/metallb_install/metallb-0.13.10/config/manifests/metallb-frr.yaml
# 修改该文件，增加node节点的 ip地址范围
kubectl  apply -f /bms/data/metallb_install/metallb-0.13.10/configsamples/ipaddresspool_simple.yaml

kubectl  apply -f /bms/data/metallb_install/nginx-deployment.yaml
kubectl expose deployment nginx-deployment --port 80 --type LoadBalancer 