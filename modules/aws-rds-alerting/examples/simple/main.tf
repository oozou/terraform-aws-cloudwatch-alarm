module "rds_alerting" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  name        = var.name

  db_instance_identifier    = "oozou-devops-demo-db"
  enabled_cloudwatch_alarms = ["cpu_high", "mem_high"]
  additional_cloudwatch_alarms = {
    cpu_high_x = {
      metric_name         = "CPUCreditUsage"
      namespace           = "AWS/RDS"
      comparison_operator = ">="
      threshold           = "10"
      evaluation_periods  = "1"
      statistic           = "Maximum"
      period              = "60"
      dimensions = {
        "DBInstanceIdentifier" = "oozou-devops-demo-db"
      }
    }
  }

  tags = var.custom_tags
}
