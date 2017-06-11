variable "access_key" {}

variable "secret_key" {}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "terraform"
}

variable "region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "site_name" {
  description = "The name of your site."
  default     = "aws-test"
}
