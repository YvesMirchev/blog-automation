app_name = "vprofile"

domain             = ""
aws_region         = "us-east-1"
vpc_name           = "vprofile-blog-vpc"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
ssh_key            = "vprofile-dev-key"

micro_instance_size = "t2.micro"
small_instance_size = "t2.small"
centos_9_ami        = "ami-0df2a11dd1fe1f8e3"
ubuntu_20_ami       = "ami-06aa3f7caf3a30282"

my_public_ip = "XXX.XXX.XXX.XXX/32"
