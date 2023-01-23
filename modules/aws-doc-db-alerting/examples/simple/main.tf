module "doc_db_alerting" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  name        = var.name

  db_cluster_identifier     = "oozou-devops-demoo-document-db"
  enabled_cloudwatch_alarms = ["cpu_high"]
  additional_cloudwatch_alarms = {
    cpu_credit = {
      metric_name         = "FreeableMemory"
      namespace           = "AWS/DocDB"
      comparison_operator = "<="
      threshold           = "1"
      evaluation_periods  = "1"
      statistic           = "Maximum"
      period              = "60"
      dimensions = {
        "DBClusterIdentifier" = "oozou-devops-demoo-document-db"
      }
    }
  }

  tags = var.custom_tags
}
