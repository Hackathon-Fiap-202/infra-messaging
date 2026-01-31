variable "queue_name" {
  description = "Nome da fila SQS"
  type        = string
}

variable "delay_seconds" {
  description = "Tempo em segundos que as mensagens ficam atrasadas antes de ficarem disponíveis para processamento"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Tamanho máximo da mensagem em bytes (máximo 256 KB)"
  type        = number
  default     = 262144 # 256 KB
}

variable "message_retention_seconds" {
  description = "Tempo em segundos que as mensagens não processadas ficam na fila (mínimo 60 segundos, máximo 14 dias)"
  type        = number
  default     = 345600 # 4 dias
}

variable "receive_wait_time_seconds" {
  description = "Tempo em segundos para long polling (0-20 segundos)"
  type        = number
  default     = 0
}

variable "visibility_timeout_seconds" {
  description = "Tempo em segundos que uma mensagem fica invisível após ser recebida"
  type        = number
  default     = 30
}

variable "dead_letter_queue_arn" {
  description = "ARN da Dead Letter Queue (opcional)"
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = "Número máximo de tentativas antes de enviar para DLQ"
  type        = number
  default     = 3
}

variable "kms_master_key_id" {
  description = "ID da chave KMS para criptografia (opcional, usa a chave padrão da AWS se não especificado)"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "Período de reutilização da chave de dados KMS em segundos"
  type        = number
  default     = 300
}

variable "enable_queue_policy" {
  description = "Habilitar política de acesso customizada para a fila"
  type        = bool
  default     = false
}

variable "queue_policy" {
  description = "Política JSON para controle de acesso à fila"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags adicionais para a fila SQS"
  type        = map(string)
  default     = {}
}

