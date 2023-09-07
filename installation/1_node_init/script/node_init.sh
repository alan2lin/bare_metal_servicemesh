# show debug info 
set -o xtrace
BASEDIR=/bms
# node package up to new  install 
sudo NEEDRESTART_MODE=a apt-get update -y
sudo NEEDRESTART_MODE=a apt-get upgrade -y

sudo NEEDRESTART_MODE=a apt-get install -y git snap make
# install docker
# https://docs.docker.com/engine/install/ubuntu/ 

sudo NEEDRESTART_MODE=a apt-get remove -y docker docker-engine docker.io containerd runc
sudo NEEDRESTART_MODE=a apt-get  install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
 echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo NEEDRESTART_MODE=a apt-get update -y
sudo NEEDRESTART_MODE=a apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

sudo docker run hello-world

# install cri-dockerd
## Forwarding IPv4 and letting iptables see bridged traffic 
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

## 等价写法
## echo -e "overlay\nbr_netfilter" | sudo tee /etc/modules-load.d/k8s.conf > /dev/null 


sudo modprobe overlay
sudo modprobe br_netfilter

### sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
## 等价写法
## echo -e "net.bridge.bridge-nf-call-iptables  = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.ipv4.ip_forward                 = 1" | sudo tee /etc/sysctl.d/k8s.conf > /dev/null

### Apply sysctl params without reboot
sudo sysctl --system

### Verify that the br_netfilter, overlay modules are loaded by running the following commands:
lsmod | grep br_netfilter
lsmod | grep overlay

### Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, and net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running the following command:
sudo sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

### verify cgroup v2   https://blog.csdn.net/Kiritow/article/details/118079768
cat /sys/fs/cgroup/cgroup.controllers

## https://github.com/Mirantis/cri-dockerd
sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo NEEDRESTART_MODE=a snap install go  --classic

## git clone https://github.com/Mirantis/cri-dockerd.git
## 如果是搭建正式环境，请不要用main版本，应该使用某一个正式版本。
## packer时，直接下载了网上的
cd ${BASEDIR}/data
cd cri-dockerd
make cri-dockerd

## Run these commands as root

sudo mkdir -p /usr/local/bin
sudo install -o root -g root -m 0755 cri-dockerd /usr/local/bin/cri-dockerd
make clean

sudo cp -a packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

cd ..

# install kubectl
## 
sudo NEEDRESTART_MODE=a apt-get update -y
sudo NEEDRESTART_MODE=a apt-get install -y apt-transport-https ca-certificates curl

K8SVER=v1.28
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8SVER}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8SVER}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list


sudo NEEDRESTART_MODE=a apt-get update -y
sudo NEEDRESTART_MODE=a apt-get install -y kubelet kubeadm kubectl
sudo NEEDRESTART_MODE=a apt-mark hold kubelet kubeadm kubectl

