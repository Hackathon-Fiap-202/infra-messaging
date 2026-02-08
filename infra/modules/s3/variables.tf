variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "dev"
}

variable "sqs_queue_urls" {
  type = map(string)
}

variable "sqs_queue_arns" {
  type = map(string)
}