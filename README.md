
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
    --set operator.replicas=1 \
    --set operator.rollOutPods=true \
    --set rollOutCiliumPods=true


kubectl create ns argocd
helm upgrade --install argocd argo/argo-cd --version 9.0.3 -n argocd -f argocd-values.yaml  --debug
kubectl apply -f ../../secrets/argocd-repo.yaml
envsubst < ../../secrets/argocd-repo.yaml | kubectl apply -f -
kubectl apply -f ../../root-app/root-app.yaml 