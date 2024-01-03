variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway per AZ"
  type        = bool
  default     = true
}

variable "my_public_ip" {
  description = "Public IP address range"
  type        = string
}

variable "domain" {
  description = "Domain name for the project"
  type        = string
}

variable "micro_instance_size" {
  description = "Size of micro instances"
  type        = string
}

variable "small_instance_size" {
  description = "Size of small instances"
  type        = string
}

variable "centos_9_ami" {
  description = "AMI ID for ctos_9_us_e1"
  type        = string
}

variable "ubuntu_20_ami" {
  description = "AMI ID for Ubuntu 20"
  type        = string
}

variable "ssh_key" {
  description = "SSH keys for the EC2 instances"
  type        = string
}

variable "app_name" {
  description = "Name of our application"
  type        = string
}
