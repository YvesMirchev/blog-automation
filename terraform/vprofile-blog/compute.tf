## ---------------------------------------------------------------------------------------------------------------------
## EC2 Instance definition
## ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "vprofile_db01" {
  ami                    = var.centos_9_ami
  instance_type          = var.small_instance_size
  key_name               = var.ssh_key
  subnet_id              = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids = [aws_security_group.vprofile_backend_sg.id]
  tags = {
    Name    = "${var.app_name}-db01"
    Project = var.app_name
  }
}

resource "aws_instance" "vprofile_mc01" {
  ami                    = var.centos_9_ami
  instance_type          = var.small_instance_size
  key_name               = var.ssh_key
  subnet_id              = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids = [aws_security_group.vprofile_backend_sg.id]
  tags = {
    Name    = "${var.app_name}-mc01"
    Project = var.app_name
  }
}

resource "aws_instance" "vprofile_rmq01" {
  ami                    = var.centos_9_ami
  instance_type          = var.small_instance_size
  key_name               = var.ssh_key
  subnet_id              = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids = [aws_security_group.vprofile_backend_sg.id]
  tags = {
    Name    = "${var.app_name}-rmq01"
    Project = var.app_name
  }
}

resource "aws_instance" "vprofile_app01" {
  ami                         = var.ubuntu_20_ami
  instance_type               = var.micro_instance_size
  key_name                    = var.ssh_key
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [aws_security_group.vprofile_app_sg.id]
  associate_public_ip_address = true
  tags = {
    Name    = "${var.app_name}-app01"
    Project = var.app_name
  }

  iam_instance_profile = aws_iam_instance_profile.s3_artifact_copy_profile.name
}

resource "aws_instance" "ansible_control" {
  ami                         = var.ubuntu_20_ami
  instance_type               = var.micro_instance_size
  key_name                    = var.ssh_key
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [aws_security_group.ansible_control_sg.id]
  associate_public_ip_address = true
  tags = {
    Name    = "ansible-control"
    Project = var.app_name
  }
}
