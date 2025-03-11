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
export KUBECONFIG=~/.kube/config
```

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