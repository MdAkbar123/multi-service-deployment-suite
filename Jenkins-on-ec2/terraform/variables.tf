variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 KeyPair to allow SSH access"
  type        = string
  default     = "Jenkins-ec2-keypair" # Set to your key pair name or leave empty for no SSH access
}

variable "private_key_path" {
  description = "Path to the private key file for SSH access"
  type        = string
  default     = "/home/akbar-ali/.ssh/Jenkins-ec2-keypair.pem" # Set to your private key path
}
variable "ami_id" {
  description = "Ubuntu AMI ID for EC2"
  type        = string
  default     = "ami-02b8269d5e85954ef" # Example for ap-south-1
}

variable "jenkins_allowed_cidr" {
  description = "CIDR allowed to access Jenkins UI (port 8080). Set to your IP/32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "jenkins_volume_size_gb" {
  description = "Root volume size (GB) for Jenkins host"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default     = {
    Project = "jenkins-ec2"
    Owner   = "terraform"
  }
}
