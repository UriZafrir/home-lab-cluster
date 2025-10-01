virsh dumpxml talos-1 > vm1
virsh dumpxml linux2024 > vm2


talosctl gen config talos-cluster https://192.168.122.158:6443 --output-dir ./cluster-config

talosctl apply-config --insecure --nodes 192.168.122.158 --file ./cluster-config/controlplane.yaml
