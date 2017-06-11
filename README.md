# Terraform Salted AWS

This is an experimental framework for quickly building salt managed
environments in AWS. It uses terraform to provision the underlying
infrastracture, and provides--what I hope is--an intuitive organization of salt
components (states, pillar, formulas, etc.). The goal is provision an entire
environment (including the salt master) with a single execution of `terraform
apply`, and then enable rapid addition of new services.


## Getting Started

1. Fork this repo
2. Clone your fork
3. `export SITE_NAME=aws-test`
3. `cp terraform/platforms/aws/terraform.tfvars.example terraform/sites/${SITE_NAME}/terraform.tfvars`
4. Review and update sites/${SITE_NAME}/terraform.tfvars
5. Run `terraform plan --var-file=terraform/sites/${SITE_NAME}/terraform.tfvars terraform/platforms/aws`
6. Run `terraform apply --var-file=terraform/sites/${SITE_NAME}/terraform.tfvars terraform/platforms/aws`
