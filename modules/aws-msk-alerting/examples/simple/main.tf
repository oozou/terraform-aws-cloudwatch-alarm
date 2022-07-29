module "kafka_alerting" {
  source = "../../"

  prefix      = var.prefix
  environment = var.environment
  name        = var.name

  kafka_cluster_name           = "oozou-devops-demo-msk"
  enabled_cloudwatch_alarms    = ["cpu_high", "disk_high", "heap_high"]
  additional_cloudwatch_alarms = {}

  tags = var.custom_tags
}
