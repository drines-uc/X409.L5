packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu22" {
  ami_name = "my_first_ami_${local.timestamp}"
  instance_type = "t2.micro"
  region        = "${var.my_region}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

source "amazon-ebs" "ubuntu20" {
  ami_name = "my_first_ami_LTS_${local.timestamp}"
  instance_type = "t2.micro"
  region        = "${var.my_region}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20231025"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}


build {
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu22",
    "source.amazon-ebs.ubuntu20",
  ]

  provisioner "file" {
    source = "app_files"
    destination = "/home/ubuntu/"
  }

  provisioner "shell" {
    inline = [
      "ls /home/ubuntu",
      "echo 'Install packages with apt'",
      "sudo apt install python3 -y",
      "sudo apt update -y",
      "sudo apt install python3-pip -y",
      "sudo snap install redis",
      "echo 'Install python pacakges with pip'",
      "sudo pip3 install -r app_files/requirements.txt",
      "echo 'Setup the my app service with systemd'",
      "sudo cp /home/ubuntu/app_files/myapp.service /etc/systemd/system/myapp.service",
      "sudo systemctl enable myapp",
    ]
  }

  

}

variable "my_region" {
  type = string
  default = "us-east-2"
}
