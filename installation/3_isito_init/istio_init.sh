# show debug info 
set -o xtrace
BASEDIR=/bms

# https://istio.io/latest/docs/setup/getting-started/
# mkdir /bms/data/istio_install/ 
# cd /bms/data/istio_install/
# wget https://github.com/istio/istio/releases/download/1.19.0/istio-1.19.0-linux-arm64.tar.gz  
# tar -xzvf istio-1.19.0-linux-arm64.tar.gz
cd /bms/data/istio_install/istio-1.19.0

./bin/istioctl install --set profile=demo -y
kubectl get ns --show-lables
kubectl label namespace default istio-injection=enabled

# 安装 bookinfo应用
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

# 添加一个pv
mkdir -p /mnt/data/
cat <<EOF |tee /bms/data/istio_install/pv-volume.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 12Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
EOF

kubectl apply -f /bms/data/istio_install/pv-volume.yaml


#安装 istio插件

# 修改 loki.yaml 
#spec.template.spec.securityContext:
#    fsGroup: 0 #10001
#	runAsNonRoot: false #true
#	runAsUser: 0 #10001
#	
#spec.template.volumeClaimTemplates.kkstorageClassName: manual

kubectl apply -f samples/addons
