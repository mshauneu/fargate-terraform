provider "aws" {
  region     = "${var.AWS_REGION}"
}
module "base_vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"

  name = "${var.NAME}"
  cidr = "10.0.0.0/16"

  azs             = ["${split(",", local.azs)}"]
  private_subnets = ["${split(",", var.CIDR_PRIVATE)}"]
  public_subnets  = ["${split(",", var.CIDR_PUBLIC)}"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

locals {
  azs = "${var.AWS_REGION}a,${var.AWS_REGION}b"
}

output "aws_region" {
  value = "${var.AWS_REGION}"
}


