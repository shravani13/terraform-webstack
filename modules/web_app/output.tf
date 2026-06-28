output "private_instance_ip" {
	value = aws_instance.web-app.private_ip
	description = "Private IP address of AWS instance created in private subnet"
}
