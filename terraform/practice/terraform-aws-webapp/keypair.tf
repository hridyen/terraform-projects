resource "tls_private_key" "web_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web_key" {
  key_name   = "terraform-web-key"
  public_key = tls_private_key.web_key.public_key_openssh
}

output "private_key_pem" {
  value     = tls_private_key.web_key.private_key_pem
  sensitive = true
}
