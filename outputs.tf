output "PUBLIC_IP"{
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}