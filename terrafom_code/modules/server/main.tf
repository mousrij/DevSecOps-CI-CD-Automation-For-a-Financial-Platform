/*

now we want a module to provision an EC2 instance 


so what an EC2 instance needs ? as dependencies
    
    - security group 
    - amazon image
    - key pair
    - user data
    - vpc_id

*/


# security group
resource "aws_security_group" "devsecops-sg" {
  name = "devsecops-sg"
  vpc_id = var.aws_vpc_id

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}



# ami - Get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "amzn_linux_img" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh-rsa" {
  key_name = "ssh-rsa-local-terraform"
  public_key = file(var.ssh_location)
}

#the instance

resource "aws_instance" "devSecOps-Ec2" {
    ami = data.aws_ami.amzn_linux_img.id
    instance_type = var.instance_type

    #subnet id
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.devsecops-sg.id]
    availability_zone = var.az

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-rsa.key_name
    user_data = file(var.entry_script)

    root_block_device {
        volume_size = var.volume_size
    }
    tags = {
      Name: "${var.server_name}"
    }


}


# -------- INGRESS RULES --------

# SSH
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

# HTTP
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

# HTTPS
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

# etcd cluster
resource "aws_vpc_security_group_ingress_rule" "etcd" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 2379
  to_port           = 2380
  cidr_ipv4         = "0.0.0.0/0"
}

# Grafana
resource "aws_vpc_security_group_ingress_rule" "grafana" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_ipv4         = "0.0.0.0/0"
}

# Kube API Server
resource "aws_vpc_security_group_ingress_rule" "kubeapi" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
  cidr_ipv4         = "0.0.0.0/0"
}

# Jenkins
resource "aws_vpc_security_group_ingress_rule" "jenkins" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_ipv4         = "0.0.0.0/0"
}

# SonarQube
resource "aws_vpc_security_group_ingress_rule" "sonarqube" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 9000
  to_port           = 9000
  cidr_ipv4         = "0.0.0.0/0"
}

# Prometheus
resource "aws_vpc_security_group_ingress_rule" "prometheus" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 9090
  to_port           = 9090
  cidr_ipv4         = "0.0.0.0/0"
}

# Prometheus Node Exporter
resource "aws_vpc_security_group_ingress_rule" "prometheus_node" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 9100
  to_port           = 9100
  cidr_ipv4         = "0.0.0.0/0"
}

# K8s internal
resource "aws_vpc_security_group_ingress_rule" "k8s_internal" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 10250
  to_port           = 10260
  cidr_ipv4         = "0.0.0.0/0"
}

# K8s NodePort
resource "aws_vpc_security_group_ingress_rule" "k8s_nodeport" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "tcp"
  from_port         = 30000
  to_port           = 32767
  cidr_ipv4         = "0.0.0.0/0"
}

# -------- EGRESS RULES --------

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.devsecops-sg.id
  ip_protocol       = "-1" # semantically equivalent to all ports
  cidr_ipv4         = "0.0.0.0/0"
}
