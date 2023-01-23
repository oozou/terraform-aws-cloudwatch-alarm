locals {
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
  aws_doc_db_namespace = "AWS/DocDB"
  dimensions = {
    "DBClusterIdentifier" = var.db_cluster_identifier
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

  enabled_cloudwatch_alarms = length(var.additional_cloudwatch_alarms) == 0 ? var.enabled_cloudwatch_alarms : concat(var.enabled_cloudwatch_alarms, keys(var.additional_cloudwatch_alarms))
  cloudwatch_alarms = merge(
    {
      cpu_high = {
        metric_name         = "CPUUtilization"
        namespace           = local.aws_doc_db_namespace
        comparison_operator = ">="
        threshold           = local.cpu_high_alert.threshold
        evaluation_periods  = local.cpu_high_alert.evaluation_periods
        statistic           = local.cpu_high_alert.statistic
        period              = local.cpu_high_alert.period
        dimensions          = local.dimensions
      }
    },
    var.additional_cloudwatch_alarms
  )
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
