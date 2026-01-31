output "sqs_queue_id" {
  description = "ID da fila SQS"
  value       = aws_sqs_queue.main.id
}

output "sqs_queue_arn" {
  description = "ARN da fila SQS"
  value       = aws_sqs_queue.main.arn
}

output "sqs_queue_url" {
  description = "URL da fila SQS"
  value       = aws_sqs_queue.main.url
}

output "sqs_queue_name" {
  description = "Nome da fila SQS"
  value       = aws_sqs_queue.main.name
}

