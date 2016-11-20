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

variable "git_deploy_repo_url" {
  description = "The location of your salt Git repo"
}

variable "git_deploy_key_path" {
  description = <<DESCRIPTION
Path to a private deploy key that grants read-only access to this Git
repo.  This deploy key will be copied to the salt node when it is first
created.

To create a deploy key, run:
  ssh-keygen -b 4096 -N '' -f terraform.git_deploy_key.id_rsa

Use the contents of terraform.git_deploy_key.id_rsa.pub to create a deploy key
for this repo through its settings in the GitHub Web UI
DESCRIPTION

  default  = "terraform.git_deploy_key.id_rsa"
}
