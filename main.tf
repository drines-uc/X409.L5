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
  region  = "us-east-2"
}


variable "vpc_id" {
  default = "vpc-05d0506be9e7da5a5"
}

resource "aws_security_group" "drines_ucsc_ssh" {
  name = "drines_test_ec2_ssh"
  vpc_id = var.vpc_id
  
  tags = {
    Name = "SEQAX409"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["99.104.37.103/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "drines_ucsc_app" {
  name = "drines_test_ec2_flask_app"
  vpc_id = var.vpc_id
  
  tags = {
    Name = "SEQAX409"
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["99.104.37.103/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["my_first_ami_*"]
  }

  owners = ["387254918478"]
}


resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.drines_ucsc_ssh.id, aws_security_group.drines_ucsc_app.id]
  key_name = "ucsc_admin"

  count = 2

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

output "hostid" {
  value = aws_instance.app_server.*.public_dns
}