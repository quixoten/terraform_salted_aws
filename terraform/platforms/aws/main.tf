# Borrowed from
# https://github.com/hashicorp/terraform/tree/master/examples/aws-two-tier


# Specify the provider and access details
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  tags = { Name = "${var.site_name}" }
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Our security group to access the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_salted_aws"
  description = "Used in the terraform_salted_aws VPC"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

data "aws_ami" "xenial" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "salt" {
  tags = {
    Name = "${var.site_name}-salt1"
  }

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.medium"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${data.aws_ami.xenial.id}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.default.id}"

  # Create working directory for provisioning
  provisioner "remote-exec" {
    inline = [
      "mkdir /tmp/terraform"
    ]
  }

  # Create an archive of the salt code to boostrap the machine with salt-call
  provisioner "local-exec" {
    command = "tar -c formulas pillar salt salt-call Saltfile|gzip > thin.tgz"
  }

  # Copy the archive to the remote machine
  provisioner "file" {
    source = "thin.tgz"
    destination = "/tmp/terraform/thin.tgz"
  }

  # Copy the salt-bootstrap provision script to the remote machine
  provisioner "file" {
    source = "terraform.provision.bootstrap-salt.sh"
    destination = "/tmp/terraform/bootstrap-salt.sh"
  }

  # Copy the salt-call provision script to the remote machine
  provisioner "file" {
    source = "terraform.provision.salt-call.sh"
    destination = "/tmp/terraform/salt-call.sh"
  }

  # We run a remote provisioner on the instance after creating it.
  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/terraform/bootstrap-salt.sh -M -X -Z stable",
      "sudo sh /tmp/terraform/salt-call.sh \"${self.tags.Name}\""
    ]
  }
}
