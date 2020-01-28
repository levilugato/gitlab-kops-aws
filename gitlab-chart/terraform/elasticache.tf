resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-subnets-${random_string.random.min_numeric}"
  subnet_ids = data.aws_subnet_ids.all.ids
}  

resource "aws_elasticache_cluster" "default" {
 cluster_id           = "${var.ENVIRO}-gitlab-codeminer42"
 engine               = "redis"
 node_type            = var.INSTANCE_ELASTICACHE_SIZE
 num_cache_nodes      = 1
 parameter_group_name = "default.redis5.0"
 engine_version       = "5.0.5"
 security_group_ids   = [var.SEC_GROUP_ELASTICACHE]
 subnet_group_name    = aws_elasticache_subnet_group.redis.name
 port                 = 6379

}