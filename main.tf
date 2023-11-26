terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5"
    }
  }
  required_version = ">= 1.3"
}

#resource "tls_private_key" "test_key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}
#
#resource "aws_key_pair" "generated_key" {
#  key_name   = "test_key"
#  public_key = tls_private_key.test_key.public_key_openssh
#}

resource "random_pet" "sg" {}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"

  # SSH ingress rule
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  # RDP ingress rule
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TCP Outgoing allow all
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP allow all
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


#ami                    = "ami-0715c1897453cabd1" // amazon linux
#ami                    = "ami-053b0d53c279acc90" // ubuntu 22.04 64-bit (x86)
#ami                    = "ami-0be0e902919675894" // Microsoft Windows Server 2022 Base

resource "aws_instance" "small" {
  ami                    = "ami-053b0d53c279acc90" // ubuntu 22.04 64-bit (x86)
  instance_type          = "t3a.nano"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = "1"
  tags = {
    Name = "Created by TF Ubuntu"
  }
}

resource "aws_instance" "powerfull" {
  ami                    = "ami-0be0e902919675894" // Microsoft Windows Server 2022 Base
  instance_type          = "t3.2xlarge"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name               = "1"
  tags = {
    Name = "Created by TF Windows 2022 Base"
  }
}


output "web-address_small_instance" {
  value = aws_instance.small.public_dns
}

output "ip-address_small_instance" {
  value = aws_instance.small.public_ip
}

output "web-address_powerfull_instance" {
  value = aws_instance.powerfull.public_dns
}

output "ip-address_powerfull_instance" {
  value = aws_instance.powerfull.public_ip
}

# fails at:
# terraform plan
# commented out:

# output "web-address_ansible_instance" {
#   value = aws_instance.ansible_on_ubuntu.public_dns
# }

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}
