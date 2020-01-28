##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "selected" {
  id = "${var.VPC}"
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.selected.id
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "gitlab-db-${var.ENVIRO}"

  engine            = "postgres"
  engine_version    = "9.6.11"
  instance_class    = var.INSTANCE_RDS_SIZE
  allocated_storage = 20
  storage_encrypted = false

  name     = "gitlab"
  username = "gitlab"
  password = "${var.DB_PASS}"
  port     = "5432"

  iam_database_authentication_enabled = false

  multi_az = var.MULTI_AZ

  subnet_ids = data.aws_subnet_ids.all.ids

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB parameter group
  family = "postgres9.6"

  # DB option group
  major_engine_version = "9.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "gitlab-db-${var.ENVIRO}"

  # Database Deletion Protection
  deletion_protection = var.DELETION_PROTETION
}