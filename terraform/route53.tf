resource "aws_route53_zone" "private" {
  name = var.CLUSTER_NAME

  vpc {
    vpc_id = module.dev_vpc.vpc_id
  }
}