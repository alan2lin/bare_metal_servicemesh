# show debug info 
set -o xtrace
BASEDIR=/bms

# install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# 安装 Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.
# https://artifacthub.io/packages/helm/metrics-server/metrics-server

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ 
# helm upgrade --install metrics-server metrics-server/metrics-server 
# helm upgrade metrics-server metrics-server/metrics-server --set args="{--kubelet-insecure-tls}" 
 helm upgrade --install metrics-server metrics-server/metrics-server --set args="{--kubelet-insecure-tls}"  