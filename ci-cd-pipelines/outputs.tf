output "public_key_openssh" {
    value = module.key_pair.public_key_openssh
}

output "public_key_pem" {
    value = module.key_pair.public_key_pem
}

output "private_key_pem" {
    value = module.key_pair.private_key_pem
    sensitive = true
}

output "private_key_id" {
    value = module.key_pair.private_key_id
}