module "sqs" {
  for_each                   = var.sqs_queues
  source                     = "./modules/sqs"
  queue_name                 = each.value.queue_name
  delay_seconds              = each.value.delay_seconds
  max_message_size           = each.value.max_message_size
  message_retention_seconds  = each.value.message_retention_seconds
  receive_wait_time_seconds  = each.value.receive_wait_time_seconds
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  dead_letter_queue_arn      = each.value.dead_letter_queue_arn
  max_receive_count          = each.value.max_receive_count
  kms_master_key_id          = each.value.kms_master_key_id
  enable_queue_policy        = each.value.enable_queue_policy
  queue_policy               = each.value.queue_policy
  tags                       = merge(var.tags, each.value.tags)
}

module "ses" {
  source = "./modules/ses"

  email_address = var.ses_email

  allowed_principals = [
    var.lambda_role_arn
  ]
}