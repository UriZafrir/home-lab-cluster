
virsh vol-create pool ../xmls/storage-1.xml
virsh vol-create pool ../xmls/storage-2.xml


virsh vol-delete talos2.qcow2 --pool pool
virsh vol-list --pool pool

virsh define

# create routed network (net-create is for transient)
sudo virsh net-define network-routed-123.xml
sudo virsh net-start talos-1
sudo virsh net-autostart talos-1

# NAT state should be active, autostart, and persistent
sudo virsh net-list --all

sudo virsh net-info talos-1
sudo virsh net-dumpxml talos-1
