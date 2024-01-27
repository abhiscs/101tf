provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-0a3c3a20c09d6f377"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = aws_key_pair.aws-key.key_name

  tags = {
    Name = "terraform-example"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo -i
                yum update -y
                yum install httpd -y
                touch /var/www/html/index.html
                echo "Hello, Sharon!" > /var/www/html/index.html
                service httpd start
                EOF

  user_data_replace_on_change = "true"
}


resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  #SSH
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTP
  ingress {
    description = "Allow HTTP traffic"
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "aws-key" {
  key_name   = "terraform-example-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

variable "server_port" {
  description = "The port server will user for HTTP requests"
  type        = number
  default     = 80
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The Public IP of the Sharon Webserver"
}