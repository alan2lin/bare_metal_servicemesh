# show debug info 
set -o xtrace
BASEDIR=/bms


# https://github.com/projectcalico/calico/issues/2042  
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
##The following two settings solve the issue.I tried to comment it out and the issue reappeared.
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1
EOF


sudo sysctl --system

sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --v=5

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "source <(kubectl completion bash)" >> ~/.bashrc


# https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises
# curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico-typha.yaml -o calico.yaml
kubectl  create -f /bms/data/k8s_addons/calico/calico.yaml

