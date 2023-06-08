# terraform-aws-cloudwatch

## Usage simeple usecase

```terraform
locals {
  comparison_operators = {
    ">=" = "GreaterThanOrEqualToThreshold",
    ">"  = "GreaterThanThreshold",
    "<"  = "LessThanThreshold",
    "<=" = "LessThanOrEqualToThreshold",
  }
}

module "step_alarm" {
  source = "<source>"

  prefix      = oozou
  environment = test
  name        = format("%s-alarm", local.service_name)

  comparison_operator = local.comparison_operators["<="]
  evaluation_periods  = "1"
  metric_name         = CPUUtilization
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = local.service_name
  }

  alarm_actions = ["arn-of-the-action"]

  tags = {"Workspace" = "xxx-yyy-zzz"}
}

```

## Usage for complex query

```terraform
locals {
  comparison_operators = {
    ">=" = "GreaterThanOrEqualToThreshold",
    ">"  = "GreaterThanThreshold",
    "<"  = "LessThanThreshold",
    "<=" = "LessThanOrEqualToThreshold",
  }
}

module "alarm" {
  source = "git@github.com:oozou/terraform-aws-cloudwatch-alarm.git?ref=<version>"

  prefix      = "oozou"
  environment = "devops"
  name        = "kafka-cpu-reach"

  comparison_operator = local.comparison_operators[">="]
  threshold           = "85"
  evaluation_periods  = 1

  # Conflict with metric_query
  metric_name = null
  namespace   = null
  period      = null
  statistic   = null
  dimensions  = null

  metric_query = [
    {
      id          = "e1"
      expression  = "m1+m2"
      label       = "CPUSummation"
      return_data = "true"
      metric      = []
    },
    {
      id = "m1"
      metric = [
        {
          metric_name = "CpuUser"
          namespace   = "AWS/Kafka"
          period      = "60"
          stat        = "Maximum"
          dimensions = {
            "Cluster Name" = "oozou-devops-demo-msk"
            "Broker ID"    = "1"
          }
        }
      ]
    },
    {
      id = "m2"
      metric = [
        {
          metric_name = "CpuSystem"
          namespace   = "AWS/Kafka"
          period      = "60"
          stat        = "Maximum"
          dimensions = {
            "Cluster Name" = "oozou-devops-demo-msk"
            "Broker ID"    = "1"
          }
        }
      ]
    }
  ]

  alarm_actions = ["arn-of-action"]

  tags = { "Workspace" = "xxx-yyy-zzz" }
}

```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                      | Version           |
|---------------------------------------------------------------------------|-------------------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0          |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 5.0.0, < 6.0.0 |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.1.0   |

## Modules

No modules.

## Resources

| Name                                                                                                                                    | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name                                                                                                                                                      | Description                                                                                                                                                                                                                                                                                                                                                                                     | Type           | Default     | Required |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|-------------|:--------:|
| <a name="input_actions_enabled"></a> [actions\_enabled](#input\_actions\_enabled)                                                                         | Indicates whether or not actions should be executed during any changes to the alarm's state. Defaults to true.                                                                                                                                                                                                                                                                                  | `bool`         | `true`      |    no    |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions)                                                                               | The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN).                                                                                                                                                                                                                                 | `list(string)` | `null`      |    no    |
| <a name="input_alarm_description"></a> [alarm\_description](#input\_alarm\_description)                                                                   | The description for the alarm.                                                                                                                                                                                                                                                                                                                                                                  | `string`       | `null`      |    no    |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator)                                                             | The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold.                                                                                                     | `string`       | n/a         |   yes    |
| <a name="input_datapoints_to_alarm"></a> [datapoints\_to\_alarm](#input\_datapoints\_to\_alarm)                                                           | The number of datapoints that must be breaching to trigger the alarm.                                                                                                                                                                                                                                                                                                                           | `number`       | `null`      |    no    |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions)                                                                                          | The dimensions for the alarm's associated metric.                                                                                                                                                                                                                                                                                                                                               | `map(string)`  | `{}`        |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                                                       | Environment Variable used as a prefix                                                                                                                                                                                                                                                                                                                                                           | `string`       | n/a         |   yes    |
| <a name="input_evaluate_low_sample_count_percentiles"></a> [evaluate\_low\_sample\_count\_percentiles](#input\_evaluate\_low\_sample\_count\_percentiles) | Used only for alarms based on percentiles. If you specify ignore, the alarm state will not change during periods with too few data points to be statistically significant. If you specify evaluate or omit this parameter, the alarm will always be evaluated and possibly change state no matter how many data points are available. The following values are supported: ignore, and evaluate. | `string`       | `null`      |    no    |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods)                                                                | The number of periods over which data is compared to the specified threshold.                                                                                                                                                                                                                                                                                                                   | `number`       | n/a         |   yes    |
| <a name="input_extended_statistic"></a> [extended\_statistic](#input\_extended\_statistic)                                                                | The percentile statistic for the metric associated with the alarm. Specify a value between p0.0 and p100.                                                                                                                                                                                                                                                                                       | `string`       | `null`      |    no    |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions)                                         | The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN).                                                                                                                                                                                                                    | `list(string)` | `null`      |    no    |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name)                                                                                     | The name for the alarm's associated metric. See docs for supported metrics.                                                                                                                                                                                                                                                                                                                     | `string`       | `null`      |    no    |
| <a name="input_metric_query"></a> [metric\_query](#input\_metric\_query)                                                                                  | Enables you to create an alarm based on a metric math expression. You may specify at most 20.                                                                                                                                                                                                                                                                                                   | `any`          | `[]`        |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                                            | Name of the ECS cluster to create                                                                                                                                                                                                                                                                                                                                                               | `string`       | n/a         |   yes    |
| <a name="input_namespace"></a> [namespace](#input\_namespace)                                                                                             | The namespace for the alarm's associated metric. See docs for the list of namespaces. See docs for supported metrics.                                                                                                                                                                                                                                                                           | `string`       | `null`      |    no    |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions)                                                                                        | The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN).                                                                                                                                                                                                                                    | `list(string)` | `null`      |    no    |
| <a name="input_period"></a> [period](#input\_period)                                                                                                      | The period in seconds over which the specified statistic is applied.                                                                                                                                                                                                                                                                                                                            | `string`       | `null`      |    no    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                                                                      | The prefix name of customer to be displayed in AWS console and resource                                                                                                                                                                                                                                                                                                                         | `string`       | n/a         |   yes    |
| <a name="input_statistic"></a> [statistic](#input\_statistic)                                                                                             | The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum                                                                                                                                                                                                                                                      | `string`       | `null`      |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                                            | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys                                                                                                                                                                                                                                                                                    | `map(any)`     | `{}`        |    no    |
| <a name="input_threshold"></a> [threshold](#input\_threshold)                                                                                             | The value against which the specified statistic is compared.                                                                                                                                                                                                                                                                                                                                    | `number`       | `null`      |    no    |
| <a name="input_threshold_metric_id"></a> [threshold\_metric\_id](#input\_threshold\_metric\_id)                                                           | If this is an alarm based on an anomaly detection model, make this value match the ID of the ANOMALY\_DETECTION\_BAND function.                                                                                                                                                                                                                                                                 | `string`       | `null`      |    no    |
| <a name="input_treat_missing_data"></a> [treat\_missing\_data](#input\_treat\_missing\_data)                                                              | Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching.                                                                                                                                                                                                                                                          | `string`       | `"missing"` |    no    |
| <a name="input_unit"></a> [unit](#input\_unit)                                                                                                            | The unit for the alarm's associated metric.                                                                                                                                                                                                                                                                                                                                                     | `string`       | `null`      |    no    |

## Outputs

| Name                                                                                                                        | Description                             |
|-----------------------------------------------------------------------------------------------------------------------------|-----------------------------------------|
| <a name="output_cloudwatch_metric_alarm_arn"></a> [cloudwatch\_metric\_alarm\_arn](#output\_cloudwatch\_metric\_alarm\_arn) | The ARN of the Cloudwatch metric alarm. |
| <a name="output_cloudwatch_metric_alarm_id"></a> [cloudwatch\_metric\_alarm\_id](#output\_cloudwatch\_metric\_alarm\_id)    | The ID of the Cloudwatch metric alarm.  |
<!-- END_TF_DOCS -->
