# Terraform Salted AWS

This is an experimental framework for using terraform to quickly build out salt
managed infrastracture in AWS. The goal is provision an entire environment
(including a salt master) with a single execution of `terraform apply`.


## Get Started

1. Fork this repo
2. Copy terraform.tfvars.example to terraform.tfvars
3. Review and update terraform.tfvars
5. Run `terraform apply`
