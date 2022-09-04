
locals {
  name = "registration-app-${replace(basename(var.component_name), "-", "-")}"
}

module "aurora" {
  source = "git::https://github.com/Bkoji1150/aws-rdscluster-kojitechs-tf.git"

  name           = local.name
  engine         = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.10.1"
  instances = {
    1 = {
      instance_class      = "db.r5.large"
      publicly_accessible = false
    }
    2 = {
      identifier     = format("%s-%s", "registration-app-${var.component_name}", "reader-instance")
      instance_class = "db.r5.2xlarge"
      promotion_tier = 15
    }
  }
  vpc_id                 = local.vpc_id
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  create_db_subnet_group = true
  create_security_group  = false
  subnets                = local.database_subnet_id

  iam_database_authentication_enabled = true
  create_random_password              = false

  apply_immediately   = false
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.example.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example.id
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}


resource "aws_db_parameter_group" "example" {
  name        = "${local.name}-aurora-db-57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-db-57-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "example" {
  name        = "${local.name}-aurora-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-57-cluster-parameter-group"
}