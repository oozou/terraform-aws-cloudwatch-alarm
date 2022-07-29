/* -------------------------------------------------------------------------- */
/*                                   Generic                                  */
/* -------------------------------------------------------------------------- */
variable "prefix" {
  description = "The prefix name of customer to be displayed in AWS console and resource"
  type        = string
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "name" {
  description = "Name of the ECS cluster to create"
  type        = string
}

variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys"
  type        = map(any)
  default     = {}
}

/* -------------------------------------------------------------------------- */
/*                             Alarm Configuration                            */
/* -------------------------------------------------------------------------- */
variable "kafka_cluster_name" {
  description = "The name of AWS MSK cluster"
  type        = string
}

variable "enabled_cloudwatch_alarms" {
  description = "Set of cloudwatch alarm to alert"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for value in var.enabled_cloudwatch_alarms : contains(
        [
          "cpu_high",
          "disk_high",
          "heap_high"
        ],
        value
      )
    ])
    error_message = "The given value is not valid choice."
  }
}

variable "additional_cloudwatch_alarms" {
  description = "(optional) Additional cloudwatch alarm"
  type        = any
  default     = {}
}

variable "default_alarm_actions" {
  description = "(optional) Default alarm action for every alarms"
  type        = list(string)
  default     = []
}
