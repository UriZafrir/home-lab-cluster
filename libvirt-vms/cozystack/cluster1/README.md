#https://cozystack.io/docs/install/kubernetes/talosctl/
#talosctl gen secrets


NODE_IP=192.168.123.74

talosctl gen config \
    cozystack https://${NODE_IP}:6443 \
    --with-secrets secrets.yaml \
    --config-patch=@patch.yaml \
    --config-patch-control-plane @patch-controlplane.yaml \
    --install-disk /dev/vda \
    --force
export TALOSCONFIG=$PWD/talosconfig

talosctl apply -f controlplane.yaml -n ${NODE_IP} -e ${NODE_IP} -i

<!-- talosctl reset --insecure --wait=false -n ${NODE_IP} -e ${NODE_IP}
talosctl reset --insecure -n 192.168.122.230 -e 192.168.122.230
talosctl reset --insecure -n 192.168.122.2 -e 192.168.122.2 -->

talosctl bootstrap -n ${NODE_IP} -e ${NODE_IP}

talosctl kubeconfig -n ${NODE_IP} -e ${NODE_IP} -f nodes/node1.yaml

export KUBECONFIG=$PWD/nodes/node1.yaml

