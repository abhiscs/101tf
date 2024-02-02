terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-0277155c3f0ab2930"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = "terraform-example"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo -i
                yum update -y
                yum install httpd -y
                sudo systemctl start httpd
                touch /var/www/html/index.html
                echo "Hello, Sharon!" > /var/www/html/index.html
                EOF
  user_data_replace_on_change = true
}

resource "aws_security_group" "instance" {
  name = "terrafrom-example-instance"
  ingress {
    from_port   = var.server_serverport
    to_port     = var.server_serverport
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
