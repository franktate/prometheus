#!/bin/bash
#
# Full list of commands required to install minikube and kube-prometheus-stack (Prometheus Operator, Grafana, dashboards, etc.)
# on Ubuntu 20.04 valid on 3/11/2023. Since kube-prometheus-stack is updated regularly and without warning, there is no guarantee that this will
# work without modification at any future point in time. 
#

sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo apt-get update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl status docker
docker run hello-world
sudo apt install -y curl wget apt-transport-https
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version -o yaml
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Start minikube: Change memory and cpus to whatever you need

minikube start --addons=ingress --install-addons=true --kubernetes-version=stable --driver=docker --memory 49152 --cpus 16 

# Install kube-prometheus-stack:

helm install prometheus prometheus-community/kube-prometheus-stack --namespace=prometheus --create-namespace --wait

# Access Uis:

# Prometheus
kubectl --namespace prometheus port-forward svc/prometheus-operated 9090 &
# Then access via http://localhost:9090
# Grafana
kubectl port-forward --namespace prometheus svc/prometheus-grafana 8080:80 &
# Then access via http://localhost:8080 and use the default grafana user:password of admin:prom-operator.
# Alert Manager
kubectl --namespace prometheus port-forward svc/prometheus-kube-prometheus-alertmanager-main 9093 &
#Then access via http://localhost:9093
