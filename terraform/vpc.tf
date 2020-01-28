module "dev_vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "2.21.0"
  name               = "${var.VPC_NAME}"
  cidr               = "${var.CIDR}.0.0/16"
  azs                = ["${var.REGION}a", "${var.REGION}b", "${var.REGION}c"]
  enable_nat_gateway = false 

  tags = {
    // This is so kops knows that the VPC resources can be used for k8s
    "kubernetes.io/cluster/${var.CLUSTER_NAME}" = "shared"
    "terraform"                                              = true
  }

  // Tags required by k8s to launch services on the right subnets
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = true
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = true
  }

}

resource "aws_internet_gateway" "gw" {
  vpc_id = module.dev_vpc.vpc_id

  tags = {
    Name = "Terraform"
  }
}