output "saltmaster_address" {
  value = ["${aws_instance.salt.*.public_ip}"]
}
