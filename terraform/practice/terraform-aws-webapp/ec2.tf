resource "aws_instance" "web" {
  ami           = "ami-020cba7c55df1f615"# Ubuntu 22.04 LTS in us-east-1
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_a.id

  security_groups = [aws_security_group.web_sg.id]

  key_name = aws_key_pair.web_key.key_name   # SSH keypair (optional, see below)

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Hello from Terraform Web App (Ubuntu + Nginx)</h1>" > /var/www/html/index.html
  EOF

  tags = { Name = "web-server" }
}
