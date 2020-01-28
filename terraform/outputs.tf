output "region" {
  value = "${var.REGION}"
}

output "vpc_id" {
  value = "${module.dev_vpc.vpc_id}"
}

output "vpc_name" {
  value = "${var.VPC_NAME}"
}

output "vpc_cidr_block" {
  value = "${module.dev_vpc.vpc_cidr_block}"
}
output "availability_zones" {
  value = ["${module.dev_vpc.azs}"]
}

/// Needed for kops

output "kubernetes_cluster_name" {
  value = "${var.CLUSTER_NAME}"
}

output "kops_state_store" {
  value = "kops-state-${var.DOMAIN}-${var.ENVIRONMENT}"
}



