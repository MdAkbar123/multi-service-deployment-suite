variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID for EC2"
  type        = string
  default     = "ami-02b8269d5e85954ef" # Example for ap-south-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = " AWS EC2 Key Pair name"
  type        = string
  default     = "my_deploy_key"
}

variable "private_key_path" {
  description = "Path to save the private key file"
  type        = string
  default     = "/home/akbar-ali/.ssh/my_deploy_key"
  
}

