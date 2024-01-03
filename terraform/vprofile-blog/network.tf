## ---------------------------------------------------------------------------------------------------------------------
## VPC Module
## ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #  version = "~> 3.0"

  name                   = var.vpc_name
  cidr                   = var.vpc_cidr
  azs                    = var.availability_zones
  private_subnets        = var.private_subnets
  public_subnets         = var.public_subnets
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}

## ---------------------------------------------------------------------------------------------------------------------
## Security Group Definition
## ---------------------------------------------------------------------------------------------------------------------

# Security Group for Load Balancer (ELB)
resource "aws_security_group" "vprofile_elb_sg" {
  name        = "${var.app_name}-elb"
  description = "Security group for vprofile prod Load Balancer"
  vpc_id      = module.vpc.vpc_id

  # Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ansible_control_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

# Security Group for Tomcat instances
resource "aws_security_group" "vprofile_app_sg" {
  name        = "${var.app_name}-app"
  description = "Security group for Tomcat instances"
  vpc_id      = module.vpc.vpc_id

  # Inbound rules
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile_elb_sg.id] # Allow traffic from ELB SG
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip] # Replace with your IP
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ansible_control_sg.id]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip] # Replace with your IP
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Security Group for Backend Services
resource "aws_security_group" "vprofile_backend_sg" {
  name        = "${var.app_name}-backend"
  description = "Security group for Vprofile Backend Services"
  vpc_id      = module.vpc.vpc_id

  # Inbound rules
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile_app_sg.id] # Allow from app-sg
  }

  ingress {
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile_app_sg.id] # Allow from app-sg
  }

  ingress {
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile_app_sg.id] # Allow from app-sg
  }

  # Allow internal traffic within the security group
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip] # Replace with your IP
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ansible_control_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Security Group for Ansible Control Machine
resource "aws_security_group" "ansible_control_sg" {
  name        = "ansible-control-sg"
  description = "Security group for Ansible Control Machine"
  vpc_id      = module.vpc.vpc_id

  # Inbound rules for SSH access from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip] # Replace with your IP
  }

  # Outbound rules to access app and backend security groups for SSH
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## SSH Key Pairs
## ---------------------------------------------------------------------------------------------------------------------

# Key Pair
resource "aws_key_pair" "dev-key" {
  key_name   = var.ssh_key
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "../../ansible/${var.ssh_key}.pem"
}

## ---------------------------------------------------------------------------------------------------------------------
## Route53 configuration
## ---------------------------------------------------------------------------------------------------------------------

# Create hosted zone for our domain
resource "aws_route53_zone" "vprofile_zone" {
  name = var.domain

  vpc {
    vpc_id     = module.vpc.vpc_id
    vpc_region = var.aws_region
  }

  tags = {
    Environment = "Dev"
  }
}

# DNS records for db01
resource "aws_route53_record" "db01_record" {
  zone_id = aws_route53_zone.vprofile_zone.zone_id
  name    = "db01.${var.domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vprofile_db01.private_ip]
}

# DNS records for mc01
resource "aws_route53_record" "mc01_record" {
  zone_id = aws_route53_zone.vprofile_zone.zone_id
  name    = "mc01.${var.domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vprofile_mc01.private_ip]
}

# DNS records for rmq01
resource "aws_route53_record" "rmq01_record" {
  zone_id = aws_route53_zone.vprofile_zone.zone_id
  name    = "rmq01.${var.domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.vprofile_rmq01.private_ip]
}

## ---------------------------------------------------------------------------------------------------------------------
## TLS certificate
## ---------------------------------------------------------------------------------------------------------------------

resource "aws_acm_certificate" "peex_cert" {
  domain_name       = "peexdevopsproject.com"
  validation_method = "DNS"

  tags = {
    Environment = "Dev"
  }
}
