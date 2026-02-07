output "sqs_queue_ids" {
  description = "Mapa de IDs das filas SQS (chave: identificador da fila, valor: ID da fila)"
  value       = { for k, v in module.sqs : k => v.sqs_queue_id }
}

output "sqs_queue_arns" {
  description = "Mapa de ARNs das filas SQS (chave: identificador da fila, valor: ARN da fila)"
  value       = { for k, v in module.sqs : k => v.sqs_queue_arn }
}

output "sqs_queue_urls" {
  description = "Mapa de URLs das filas SQS (chave: identificador da fila, valor: URL da fila)"
  value       = { for k, v in module.sqs : k => v.sqs_queue_url }
}

output "sqs_queue_names" {
  description = "Mapa de nomes das filas SQS (chave: identificador da fila, valor: nome da fila)"
  value       = { for k, v in module.sqs : k => v.sqs_queue_name }
}

output "sqs_queues" {
  description = "Mapa completo com todas as informações das filas SQS"
  value = {
    for k, v in module.sqs : k => {
      id   = v.sqs_queue_id
      arn  = v.sqs_queue_arn
      url  = v.sqs_queue_url
      name = v.sqs_queue_name
    }
  }
}

output "ses_email_identity_arns" {
  description = "Mapa de ARNs das identidades de email do SES (chave: identificador da identidade, valor: ARN)"
  value       = module.ses.ses_email_identity_arn
}