output "mac_ami" {
  value = data.aws_ami.mac.id
}

output "dedicated_host_id" {
  value = module.dedicated-host.dedicated_host_id
}

output "private_key" {
  value     = tls_private_key.rsa_key.private_key_pem
  sensitive = true
}