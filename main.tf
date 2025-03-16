resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
  tags = { Name = "public-subnet-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1b"
  tags = { Name = "public-subnet-2" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "ap-southeast-1a"
  tags = { Name = "private-subnet-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "ap-southeast-1b"
  tags = { Name = "private-subnet-2" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    # from_port   = 22
    # to_port     = 22
    # protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["171.243.49.1/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "ec2-security-group" }
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "my-ec2-key"
  public_key = file("~/.ssh/rsa_key_withoutpass.pub")
}

# Fetch K3S_TOKEN from local WSL2
resource "null_resource" "fetch_k3s_token" {
  provisioner "local-exec" {
    command = "sudo cat /var/lib/rancher/k3s/server/node-token > k3s_token.txt"
    interpreter = ["bash", "-c"]
  }
}

# Read the token file into Terraform
data "external" "k3s_token" {
  program = ["bash", "-c", "echo '{\"token\": \"'$(cat k3s_token.txt)'\"}'"]

  depends_on = [null_resource.fetch_k3s_token]
}

# EC2 Instance
resource "aws_instance" "web_servers" {
  count                  = 2
  ami                    = "ami-0672fd5b9210aa093"
  instance_type          = var.instance_type
  subnet_id              = element([aws_subnet.public_1.id, aws_subnet.public_2.id], count.index)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.ec2_key.key_name
  tags = { Name = "web-server-${count.index + 1}" }

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    k3s_token = data.external.k3s_token.result["token"]
  })

  depends_on = [null_resource.fetch_k3s_token]
}

# SSH Reverse Tunnel from WSL2 to EC2
resource "null_resource" "ssh_tunnel" {
  count      = 2  # Match the number of EC2 instances
  depends_on = [aws_instance.web_servers]

  provisioner "local-exec" {
    command = "autossh -M 0 -f -N -o 'StrictHostKeyChecking=no' -o 'ExitOnForwardFailure=yes' -R 6443:localhost:6443 ubuntu@${aws_instance.web_servers[count.index].public_ip} -i ~/.ssh/rsa_key_withoutpass"
    interpreter = ["bash", "-c"]
  }
}
