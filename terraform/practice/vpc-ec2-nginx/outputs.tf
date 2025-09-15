output "instance_public_ip" {
  
  description = "this is the public  ip  of  the ec"
  value       = "${aws_instance.nginxserver.public_ip}"
}

output "instance_url" {
    description = "this is the url"
    value       = "http://${aws_instance.nginxserver.public_ip}:80"
  
}