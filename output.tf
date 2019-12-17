# Outputs
output "public_ips" {
  value = aws_eip.Servers.*.public_ip
}

output "private_ips" {
  value = aws_instance.server.*.private_ip
}
