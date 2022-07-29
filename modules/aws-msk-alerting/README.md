<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 4.00  |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.23.0  |

## Modules

| Name                                                | Source | Version |
|-----------------------------------------------------|--------|---------|
| <a name="module_alarm"></a> [alarm](#module\_alarm) | ../../ | n/a     |

## Resources

| Name                                                                                                                         | Type        |
|------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_msk_broker_nodes.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/msk_broker_nodes) | data source |
| [aws_msk_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/msk_cluster)           | data source |

## Inputs

| Name                                                                                                                       | Description                                                                                                  | Type           | Default | Required |
|----------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_additional_cloudwatch_alarms"></a> [additional\_cloudwatch\_alarms](#input\_additional\_cloudwatch\_alarms) | (optional) Additional cloudwatch alarm                                                                       | `any`          | `{}`    |    no    |
| <a name="input_default_alarm_actions"></a> [default\_alarm\_actions](#input\_default\_alarm\_actions)                      | (optional) Default alarm action for every alarms                                                             | `list(string)` | `[]`    |    no    |
| <a name="input_enabled_cloudwatch_alarms"></a> [enabled\_cloudwatch\_alarms](#input\_enabled\_cloudwatch\_alarms)          | Set of cloudwatch alarm to alert                                                                             | `list(string)` | `[]`    |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                        | Environment Variable used as a prefix                                                                        | `string`       | n/a     |   yes    |
| <a name="input_kafka_cluster_name"></a> [kafka\_cluster\_name](#input\_kafka\_cluster\_name)                               | The name of AWS MSK cluster                                                                                  | `string`       | n/a     |   yes    |
| <a name="input_name"></a> [name](#input\_name)                                                                             | Name alarm                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                                       | The prefix name of customer to be displayed in AWS console and resource                                      | `string`       | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                             | Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys | `map(any)`     | `{}`    |    no    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
