kubectl create ns cozy-system
kubectl apply -f cozystack.yaml
kubectl apply -f https://github.com/cozystack/cozystack/releases/latest/download/cozystack-installer.yaml

kubectl create -f metallb-l2-advertisement.yml
kubectl create -f metallb-ip-address-pool.yml

kubectl patch -n cozy-system configmap cozystack --type=merge -p '{
  "data": {
    "expose-external-ips": "192.168.122.217,192.168.122.2"
  }
}'

kubectl patch -n tenant-root ingresses.apps.cozystack.io ingress --type=merge -p '{
  "spec":{
    "externalIPs": [
      "192.168.122.217",
      "192.168.122.2"
    ]
  }
}'