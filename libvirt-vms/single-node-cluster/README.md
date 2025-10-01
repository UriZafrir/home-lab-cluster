NODE_IP=192.168.123.90

talosctl gen secrets
<!-- talosctl gen config single-node-cluster https://${NODE_IP}:6443 --install-disk /dev/vda --config-patch @cluster-patch.yaml --with-secrets secrets.yaml -->

talosctl gen config \
    cozystack https://${NODE_IP}:6443 \
    --with-secrets secrets.yaml \
    --config-patch=@patch.yaml \
    --config-patch-control-plane @patch-controlplane.yaml \
    --install-disk /dev/vda \
    --force
export TALOSCONFIG=$PWD/talosconfig

talosctl -n ${NODE_IP} apply-config --insecure --file controlplane.yaml

talosctl -n ${NODE_IP} -e ${NODE_IP} bootstrap


rm ~/.kube/config
talosctl kubeconfig -n ${NODE_IP} -e ${NODE_IP} -f ~/.kube/config

#for reapplying the generated config use without --insecure:
#talosctl apply-config --endpoints ${NODE_IP} -n ${NODE_IP} -f controlplane.yaml



#cilium
#https://www.talos.dev/v1.11/kubernetes-guides/network/deploying-cilium/
helm upgrade --install \
    cilium \
    cilium/cilium \
    --version 1.18.0 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=true \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set k8sServiceHost=localhost \
    --set k8sServicePort=7445 \
    --set operator.replicas=1

kubectl create ns argocd
helm upgrade --install argocd argo/argo-cd --version 8.5.7 -n argocd --set server.service.type=NodePort --debug
