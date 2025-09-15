resource "aws_instance" "nginxserver" {
  ami           = "ami-020cba7c55df1f615" # Ubuntu AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
  tags = {
    Name = "MyUbuntuNginxServer"
  }
}

