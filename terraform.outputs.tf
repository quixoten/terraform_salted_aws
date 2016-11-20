output "public_ip" {
  value = ["${aws_instance.salt.*.public_ip}"]
}
