### Ensure your system is up-to-date:
```bash
sudo apt update && sudo apt upgrade -y

### Install common dependencies:
```bash
sudo apt install -y curl wget autossh

### Run the following command to install k3s:
```bash
curl -sfL https://get.k3s.io | sh -

### Check the status of the k3s service:
```bash
sudo systemctl status k3s

### Accessing the Kubeconfig File
```bash
mkdir mkdir ~/.kube
sudo scp /etc/rancher/k3s/k3s.yaml ~/.kube/config
export KUBECONFIG=~/.kube/config


# Terraform
### Store AWS's Access Key
```bash
mkdir ~/.aws
touch ~/.aws/credentials

### Write access key to credentials file
```ini
[default]
aws_access_key_id=<your-key>
aws_secret_access_key=<your-key>

### run Terraform
1.Initialize Terraform:
```bash
terraform init

terraform plan

terraform apply -auto-approve

terraform destroy -auto-approve