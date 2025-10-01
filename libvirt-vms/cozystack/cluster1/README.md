https://cozystack.io/docs/install/kubernetes/talosctl/

talosctl gen config \
    cozystack https://192.168.122.217:6443 \
    --with-secrets secrets.yaml \
    --config-patch=@patch.yaml \
    --config-patch-control-plane @patch-controlplane.yaml
export TALOSCONFIG=$PWD/talosconfig

talosctl gen config \
    cozystack https://192.168.122.217:6443 \
    --with-secrets secrets.yaml \
    --config-patch=@patch.yaml \
    --config-patch-control-plane @patch-controlplane.yaml \
    --force
export TALOSCONFIG=$PWD/talosconfig

talosctl apply -f controlplane.yaml -n 192.168.122.217 -e 192.168.122.217 -i
talosctl apply -f controlplane.yaml -n 192.168.122.230 -e 192.168.122.230 -i
talosctl apply -f controlplane.yaml -n 192.168.122.2 -e 192.168.122.2 -i

<!-- talosctl reset --insecure --wait=false -n 192.168.122.217 -e 192.168.122.217
talosctl reset --insecure -n 192.168.122.230 -e 192.168.122.230
talosctl reset --insecure -n 192.168.122.2 -e 192.168.122.2 -->


timeout 60 sh -c 'until nc -nzv 192.168.122.217 50000 && \
  nc -nzv 192.168.122.230 50000 && \
  nc -nzv 192.168.122.2 50000; \
  do sleep 1; done'

talosctl bootstrap -n 192.168.122.217 -e 192.168.122.217

talosctl kubeconfig -n 192.168.122.217 -e 192.168.122.217 -f nodes/node1.yaml

export KUBECONFIG=$PWD/nodes/node1.yaml

