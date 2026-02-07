variable "region" {
  description = "Região da AWS"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags aplicadas aos recursos"
}

# SQS
variable "sqs_queues" {
  description = "Mapa de filas SQS a serem criadas. A chave é um identificador único e o valor contém as configurações da fila."
  type = map(object({
    queue_name                 = string
    delay_seconds              = optional(number, 0)
    max_message_size           = optional(number, 262144)
    message_retention_seconds  = optional(number, 345600)
    receive_wait_time_seconds  = optional(number, 0)
    visibility_timeout_seconds = optional(number, 30)
    dead_letter_queue_arn      = optional(string, null)
    max_receive_count          = optional(number, 3)
    kms_master_key_id          = optional(string, null)
    enable_queue_policy        = optional(bool, false)
    queue_policy               = optional(string, null)
    tags                       = optional(map(string), {})
  }))
  default = {}
}

variable "ses_email" {
  type = string
}

variable "role_arn" {
  type = string
}

