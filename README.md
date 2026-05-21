curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="server \
      --disable=traefik \
      --disable=servicelb \
      --default-local-storage-path=/mnt/uri/data/k3s-ubuntu-storage" \
  sh -

or

sudo mkdir -p /etc/rancher/k3s

cat <<EOF | sudo tee /etc/rancher/k3s/config.yaml > /dev/null
disable:
  - traefik
  - servicelb
flannel-backend: "none"
disable-network-policy: true
disable-kube-proxy: true
default-local-storage-path: "/mnt/data/k3s-ubuntu-storage"
EOF

cat /etc/rancher/k3s/config.yaml

curl -sfL https://get.k3s.io | sh -

mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown uri:uri ~/.kube/config

#for k8sServicePort
#kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 


helm repo add cilium https://helm.cilium.io/

#cilium
#https://www.talos.dev/v1.11/kubernetes-guides/network/deploying-cilium/
helm upgrade --install \
    cilium \
    cilium/cilium \
    --version 1.20.0-pre.0 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=true \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set k8sServiceHost=localhost \
    --set k8sServicePort=6443 \
    --set operator.replicas=1 \
    --set operator.rollOutPods=true \
    --set rollOutCiliumPods=true

helm repo add argo https://argoproj.github.io/argo-helm
kubectl create ns argocd
helm upgrade --install argocd argo/argo-cd --version 9.5.15 -n argocd -f argocd-values.yaml --debug
envsubst < secrets/argocd-repo.yaml | kubectl apply -f -
kubectl apply -f root-app/root-app.yaml
