output "sqs_queue_id" {
  description = "ID da fila SQS"
  value = {
    for name, queue in aws_sqs_queue.main :
    name => queue.id
  }
}

output "sqs_queue_url" {
  description = "URLs das filas SQS"
  value = {
    for name, queue in aws_sqs_queue.main :
    name => queue.url
  }
}

output "sqs_queue_arn" {
  description = "ARNs das filas SQS"
  value = {
    for name, queue in aws_sqs_queue.main :
    name => queue.arn
  }
}

output "sqs_queue_name" {
  value = {
    for name, queue in aws_sqs_queue.main :
    name => queue.name
  }
}

