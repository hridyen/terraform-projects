# EC2 Instance Public IP
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

# EC2 Instance Public DNS
output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web.public_dns
}

# Load Balancer DNS
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

