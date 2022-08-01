<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.24.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alarm"></a> [alarm](#module\_alarm) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_metric_filter.free_mem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.inactive_mem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.total_mem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_cloudwatch_alarms"></a> [additional\_cloudwatch\_alarms](#input\_additional\_cloudwatch\_alarms) | (optional) Additional cloudwatch alarm | `any` | `{}` | no |
| <a name="input_db_instance_identifier"></a> [db\_instance\_identifier](#input\_db\_instance\_identifier) | The name of the RDS instance | `string` | n/a | yes |
| <a name="input_default_alarm_actions"></a> [default\_alarm\_actions](#input\_default\_alarm\_actions) | (optional) Default alarm action for every alarms | `list(string)` | `[]` | no |
| <a name="input_enabled_cloudwatch_alarms"></a> [enabled\_cloudwatch\_alarms](#input\_enabled\_cloudwatch\_alarms) | Set of cloudwatch alarm to alert | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment Variable used as a prefix | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name alarm | `string` | n/a | yes |
| <a name="input_override_cpu_high_alert"></a> [override\_cpu\_high\_alert](#input\_override\_cpu\_high\_alert) | Key value to override default configuration; possible keys: {threshold, evaluation\_periods, statistic, period} | `map(any)` | `{}` | no |
| <a name="input_override_mem_high_alert"></a> [override\_mem\_high\_alert](#input\_override\_mem\_high\_alert) | Key value to override default configuration; possible keys: {threshold, evaluation\_periods, statistic, period} | `map(any)` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix name of customer to be displayed in AWS console and resource | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys | `map(any)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
