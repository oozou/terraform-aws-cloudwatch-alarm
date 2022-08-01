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
  cpu_high_alert = merge(
    {
      threshold          = 85
      evaluation_periods = "1"
      statistic          = "Maximum"
      period             = "300"
    },
    var.override_cpu_high_alert
  )

  disk_high_alert = merge(
    {
      threshold          = 85
      evaluation_periods = "1"
      statistic          = "Maximum"
      period             = "300"
    },
    var.override_disk_high_alert
  )

  heap_high_alert = merge(
    {
      threshold          = 60
      evaluation_periods = "1"
      statistic          = "Maximum"
      period             = "300"
    },
    var.override_heap_high_alert
  )
}

locals {
  is_contain_cpu_high  = contains(var.enabled_cloudwatch_alarms, "cpu_high")
  is_contain_disk_high = contains(var.enabled_cloudwatch_alarms, "disk_high")
  is_contain_heap_high = contains(var.enabled_cloudwatch_alarms, "heap_high")
  broker_ids           = [for node in data.aws_msk_broker_nodes.this.node_info_list : node.broker_id]
  enabled_cloudwatch_alarms = concat(
    keys(var.additional_cloudwatch_alarms),
    local.is_contain_cpu_high ? [for broker_id in local.broker_ids : format("cpu_high_broker_%s", broker_id)] : [],
    local.is_contain_disk_high ? [for broker_id in local.broker_ids : format("disk_high_broker_%s", broker_id)] : [],
    local.is_contain_heap_high ? [for broker_id in local.broker_ids : format("heap_high_broker_%s", broker_id)] : []
  )

  dimensions = { for broker_id in local.broker_ids : broker_id => {
    "Cluster Name" : var.kafka_cluster_name,
    "Broker ID" : format("%s", broker_id) }
  }

  metric_query_cpu_high_alarms = { for idx, broker_id in local.broker_ids : format("broker_%s", broker_id) => [
    {
      id          = "e1"
      expression  = "cpu_user+cpu_system"
      label       = "CPUSummation"
      return_data = "true"
      metric      = []
    },
    {
      id = "cpu_user"
      metric = [
        {
          metric_name = "CpuUser"
          namespace   = "AWS/Kafka"
          period      = local.cpu_high_alert.period
          stat        = local.cpu_high_alert.statistic
          dimensions  = local.dimensions[broker_id]
        }
      ]
    },
    {
      id = "cpu_system"
      metric = [
        {
          metric_name = "CpuSystem"
          namespace   = "AWS/Kafka"
          period      = local.cpu_high_alert.period
          stat        = local.cpu_high_alert.statistic
          dimensions  = local.dimensions[broker_id]
        }
      ]
    }
  ] }
  cpu_high_alarms = { for broker_id, metric_query in local.metric_query_cpu_high_alarms : format("cpu_high_%s", broker_id) => {
    "comparison_operator" : ">="
    "evaluation_periods" : local.cpu_high_alert.evaluation_periods
    "threshold" : local.cpu_high_alert.threshold
    "alarm_actions" : []
    "metric_query" : metric_query
    }
  }

  disk_high_alarms = { for broker_id in local.broker_ids : format("disk_high_broker_%s", broker_id) => {
    namespace           = "AWS/Kafka"
    metric_name         = "KafkaDataLogsDiskUsed"
    statistic           = local.disk_high_alert.statistic
    comparison_operator = ">="
    threshold           = local.disk_high_alert.threshold
    period              = local.disk_high_alert.period
    evaluation_periods  = local.disk_high_alert.evaluation_periods
    dimensions          = local.dimensions[broker_id]
    alarm_actions       = []
    }
  }

  heap_high_alarms = { for broker_id in local.broker_ids : format("heap_high_broker_%s", broker_id) => {
    namespace           = "AWS/Kafka"
    metric_name         = "HeapMemoryAfterGC"
    statistic           = local.heap_high_alert.statistic
    comparison_operator = ">="
    threshold           = local.heap_high_alert.threshold
    period              = local.heap_high_alert.period
    evaluation_periods  = local.heap_high_alert.evaluation_periods
    dimensions          = local.dimensions[broker_id]
    alarm_actions       = []
    }
  }

  cloudwatch_alarms = merge(
    local.cpu_high_alarms,
    local.disk_high_alarms,
    local.heap_high_alarms,
    var.additional_cloudwatch_alarms
  )
}

data "aws_msk_cluster" "this" {
  cluster_name = var.kafka_cluster_name
}

data "aws_msk_broker_nodes" "this" {
  cluster_arn = data.aws_msk_cluster.this.arn
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
