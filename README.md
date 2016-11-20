# Terraform Salted AWS

This is an experimental framework for quickly building salt managed
environments in AWS. It uses terraform to provision the underlying
infrastracture, and provides--what I hope is--an intuitive organization of salt
components (states, pillar, formulas, etc.). The goal is provision an entire
environment (including the salt master) with a single execution of `terraform
apply`, and then enable rapid addition of new services.


## Getting Started

1. Fork this repo
2. Copy terraform.tfvars.example to terraform.tfvars
3. Review and update terraform.tfvars
5. Run `terraform apply`
