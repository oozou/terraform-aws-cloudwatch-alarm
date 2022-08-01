locals {
  name = format("%s-%s-%s", var.prefix, var.environment, var.name)

  comparison_operators = {
    ">=" = "GreaterThanOrEqualToThreshold",
    ">"  = "GreaterThanThreshold",
    "<"  = "LessThanThreshold",
    "<=" = "LessThanOrEqualToThreshold",
  }

  tags = merge(
    {
      "Environment" = var.environment,
      "Terraform"   = "true"
    },
    var.tags
  )
}

locals {
  aws_rds_namespace    = "AWS/RDS"
  custom_rds_namespace = "RDSInfo"
  dimensions = {
    "DBInstanceIdentifier" = var.db_instance_identifier
  }

  cpu_high_alert = merge(
    {
      threshold          = 85
      evaluation_periods = "1"
      statistic          = "Maximum"
      period             = "300"
    },
    var.override_cpu_high_alert
  )

  mem_high_alert = merge(
    {
      threshold          = 85
      evaluation_periods = "1"
      statistic          = "Maximum"
      period             = "60"
    },
    var.override_mem_high_alert
  )

  enabled_cloudwatch_alarms = length(var.additional_cloudwatch_alarms) == 0 ? var.enabled_cloudwatch_alarms : concat(var.enabled_cloudwatch_alarms, keys(var.additional_cloudwatch_alarms))
  cloudwatch_alarms = merge(
    {
      cpu_high = {
        metric_name         = "CPUUtilization"
        namespace           = local.aws_rds_namespace
        comparison_operator = ">="
        threshold           = local.cpu_high_alert.threshold
        evaluation_periods  = local.cpu_high_alert.evaluation_periods
        statistic           = local.cpu_high_alert.statistic
        period              = local.cpu_high_alert.period
        dimensions          = local.dimensions
      }
      mem_high = {
        comparison_operator = ">="
        evaluation_periods  = local.mem_high_alert.evaluation_periods
        threshold           = local.mem_high_alert.threshold
        alarm_actions       = []
        metric_query = [
          {
            id          = "e1"
            expression  = "100-((free_mem+inactive_mem)*100/total_mem)"
            label       = "MemoryUtilization"
            return_data = "true"
            metric      = []
          },
          {
            id = "free_mem"
            metric = [
              {
                metric_name = "MemoryFree"
                namespace   = local.custom_rds_namespace
                period      = local.mem_high_alert.period
                stat        = local.mem_high_alert.statistic
              }
            ]
          },
          {
            id = "inactive_mem"
            metric = [
              {
                metric_name = "MemoryInactive"
                namespace   = local.custom_rds_namespace
                period      = local.mem_high_alert.period
                stat        = local.mem_high_alert.statistic
              }
            ]
          },
          {
            id = "total_mem"
            metric = [
              {
                metric_name = "MemoryTotal"
                namespace   = "RDSInfo"
                period      = local.mem_high_alert.period
                stat        = local.mem_high_alert.statistic
              }
            ]
          }
        ]
      }
    },
    var.additional_cloudwatch_alarms
  )
}

# data "aws_db_instance" "this" {
#   db_instance_identifier = var.db_instance_identifier
# }

resource "aws_cloudwatch_log_metric_filter" "total_mem" {
  count = contains(local.enabled_cloudwatch_alarms, "mem_high") && !contains(keys(var.additional_cloudwatch_alarms), "mem_high") ? 1 : 0

  name           = format("%s-total-mem", local.name)
  pattern        = "{$.instanceID = \"${var.db_instance_identifier}\"}"
  log_group_name = "RDSOSMetrics"

  metric_transformation {
    name      = "MemoryTotal"
    namespace = local.custom_rds_namespace
    value     = "$.memory.total"
    unit      = "Kilobytes"
  }
}

resource "aws_cloudwatch_log_metric_filter" "free_mem" {
  count = contains(local.enabled_cloudwatch_alarms, "mem_high") && !contains(keys(var.additional_cloudwatch_alarms), "mem_high") ? 1 : 0

  name           = format("%s-free-mem", local.name)
  pattern        = "{$.instanceID = \"${var.db_instance_identifier}\"}"
  log_group_name = "RDSOSMetrics"

  metric_transformation {
    name      = "MemoryFree"
    namespace = local.custom_rds_namespace
    value     = "$.memory.free"
    unit      = "Kilobytes"
  }
}

resource "aws_cloudwatch_log_metric_filter" "inactive_mem" {
  count = contains(local.enabled_cloudwatch_alarms, "mem_high") && !contains(keys(var.additional_cloudwatch_alarms), "mem_high") ? 1 : 0

  name           = format("%s-inactive-mem", local.name)
  pattern        = "{$.instanceID = \"${var.db_instance_identifier}\"}"
  log_group_name = "RDSOSMetrics"

  metric_transformation {
    name      = "MemoryInactive"
    namespace = local.custom_rds_namespace
    value     = "$.memory.inactive"
    unit      = "Kilobytes"
  }
}

module "alarm" {
  source = "../../"

  for_each = toset(local.enabled_cloudwatch_alarms)

  prefix      = var.prefix
  environment = var.environment
  name        = format("%s-%s", var.name, replace(each.key, "_", "-"))

  comparison_operator = local.comparison_operators[lookup(local.cloudwatch_alarms[each.key], "comparison_operator", null)]
  evaluation_periods  = lookup(local.cloudwatch_alarms[each.key], "evaluation_periods", null)
  metric_name         = lookup(local.cloudwatch_alarms[each.key], "metric_name", null)
  metric_query        = lookup(local.cloudwatch_alarms[each.key], "metric_query", [])
  namespace           = lookup(local.cloudwatch_alarms[each.key], "namespace", null)
  period              = lookup(local.cloudwatch_alarms[each.key], "period", null)
  statistic           = lookup(local.cloudwatch_alarms[each.key], "statistic", null)
  threshold           = lookup(local.cloudwatch_alarms[each.key], "threshold", null)
  dimensions          = lookup(local.cloudwatch_alarms[each.key], "dimensions", null)

  alarm_actions = lookup(local.cloudwatch_alarms[each.key], "alarm_actions", var.default_alarm_actions)

  tags = local.tags
}
