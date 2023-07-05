terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

provider "random" {}

resource "random_pet" "name" {}


resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.rsa_key.private_key_pem}' > macos_key.pem
    EOT
  }
}

module "dedicated-host" {
  source            = "DanielRDias/dedicated-host/aws"
  version           = "1.0.0"
  instance_type     = "mac1.metal"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "Terraform Mac"
  }
}

resource "aws_instance" "mac" {
  ami                    = data.aws_ami.mac.id
  instance_type          = "mac1.metal"
  host_id                = module.dedicated-host.dedicated_host_id
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  tags = {
    Name = "Terraform Mac"
  }
}

data "aws_ami" "mac" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ec2-macos-12*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "web-sg" {
  name        = "${random_pet.name.id}-sg"
  description = "Allow HTTP inbound traffic"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}