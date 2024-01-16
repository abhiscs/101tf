provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
    ami="ami-079db87dc4c10ac91"
    instance_type="t2.micro"
	vpc_security_group_ids = [aws_security_group.instance.id]

    tags = {
    Name="tf-example"
    }

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello Jina" > index.xhtml
                nohup buzybox httpd -f -p 8080 &
                EOF
    user_data_replace_on_change = "true"
}

resource "aws_security_group" "instance" {
	name = "tf-example-instance"
    ingress {
        from_port=8080
		to_port=8080
		protocol="tcp"
		cidr_blocks=["0.0.0.0/0"]
    }
}