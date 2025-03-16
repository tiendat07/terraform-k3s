# Install K3s
### Ensure your system is up-to-date:
```bash
sudo apt update && sudo apt upgrade -y
```

### Install common dependencies:
```bash
sudo apt install -y curl wget autossh
```

### Run the following command to install k3s:
```bash
curl -sfL https://get.k3s.io | sh -
```

### Check the status of the k3s service:
```bash
sudo systemctl status k3s
```

### Accessing the Kubeconfig File
```bash
mkdir mkdir ~/.kube
sudo scp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown datdao:datdao ~/.kube/config
export KUBECONFIG=~/.kube/config
```

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes

## Steps to Allow Passwordless Sudo
1. Open the Sudoers File for Editing:

Use the visudo command to safely edit the sudoers file:
```bash
sudo visudo
```
2. Add the Passwordless Sudo Rule:

Scroll down to the end of the file and add the following line:
```bash
$youruser ALL=(ALL) NOPASSWD: ALL
```


# Terraform Setup
### Store AWS Access Keys
1. Create the ```.aws``` directory and ```credentials``` file:
```bash
mkdir ~/.aws
touch ~/.aws/credentials
```

2. Write access key to ```credentials``` file
```ini
[default]
aws_access_key_id=<your-key>
aws_secret_access_key=<your-key>
```

### Run Terraform Commands
1.Initialize Terraform:
```bash
terraform init

terraform plan

terraform apply -auto-approve

terraform destroy -auto-approve
```

# Download Helm charts
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
./get_helm.sh
helm version

# Install Nginx Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --set controller.hostNetwork=true,controller.service.type="",controller.kind=DaemonSet --namespace ingress-nginx --version 4.10.1 --create-namespace --debug

### Run yaml values
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  -f ./ingress-nginx/ingress-nginx-values.yaml \
  --version 4.10.1 \
  --create-namespace \
  --debug

### run with load balance type and automate assign 1 of my EC2 node as Load Balancer
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --version 4.10.1 \
  --debug


kubectl get pods --all-namespaces



### Verify installation
kubectl -n ingress-nginx get pods
kubectl -n ingress-nginx get svc
kubectl -n ingress-nginx get daemonsets

kubectl -n ingress-nginx describe pod <pod-name>

kubectl delete clusterrole ingress-nginx # delete ClusterRole
kubectl delete clusterrolebinding ingress-nginx

kubectl delete namespaces ingress-nginx

# Install MinIO
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install minio -n minio -f ./minio/minio-values.yaml bitnami/minio --create-namespace --debug --version 14.6.0
kubectl -n minio get pods
kubectl -n minio get svc
kubectl -n minio get ingress
kubectl get no -owide

### Add the following lines to the end of the /etc/hosts
172.18.0.4 minio.lakehouse.local
(your IP address for Minio UI) 

echo "18.139.225.211 minio.lakehouse.local" | sudo tee -a /etc/hosts


