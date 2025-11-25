terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

##############################################
# Auto-generate SSH key every run
#############################################

resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_keypair" {
  key_name   = var.key_name 
  public_key = tls_private_key.jenkins_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.jenkins_key.private_key_pem
  filename        = var.private_key_path
  file_permission = "0400"
}


output "ssh_key_name" {
  value = aws_key_pair.jenkins_keypair.key_name
}

#############################################
# Lookup default VPC / subnet so this is simple to run
#############################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#############################################
# Security Group
#############################################
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH (your IP) and Jenkins UI (8080 restricted)"
  vpc_id      = data.aws_vpc.default.id
  tags        = var.tags

  # Allow Jenkins UI from your IP only (variable)
  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.jenkins_allowed_cidr]
  }

  # Optional SSH access - only if key_name is set, allow from same CIDR
  ingress {
    description = "SSH (set key_name & open for your IP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.jenkins_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#############################################
# IAM role & instance profile (EC2 -> ECR access)
#############################################
resource "aws_iam_role" "ec2_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Attach managed policy giving ECR access (and EC2 basic)
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_instance_profile_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "jenkins-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

#############################################
# EC2 Instance (Ubuntu 22.04) + simple user data to install Docker & enable it
# For production use, prefer Ansible for configuration (recommended).
#############################################
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = aws_key_pair.jenkins_keypair.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  root_block_device {
    volume_size = var.jenkins_volume_size_gb
    volume_type = "gp3"
    delete_on_termination = true
  }

  tags = merge(var.tags, { Name = "jenkins-controller" })
}

#   user_data = <<-EOF
#               #!/bin/bash
#               set -e
#               apt-get update -y
#               apt-get upgrade -y
#               # install Docker
#               apt-get install -y ca-certificates curl gnupg lsb-release
#               mkdir -p /etc/apt/keyrings
#               curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#               echo \
#               "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#               $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
#               apt-get update -y
#               apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
#               # add ubuntu default user (if present) and 'admin' to docker group
#               if id -u ubuntu >/dev/null 2>&1; then
#                 usermod -aG docker ubuntu || true
#               fi
#               if id -u admin >/dev/null 2>&1; then
#                 usermod -aG docker admin || true
#               fi
#               # create jenkins home dir (if Ansible not used)
#               mkdir -p /var/jenkins_home
#               chown -R 1000:1000 /var/jenkins_home || true
#               # enable docker
#               systemctl enable docker
#               systemctl start docker
#               EOF
# }
