output "public_dns" {
  value = one(aws_instance.this[*].public_dns)
}
