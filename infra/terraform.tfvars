aws_region = "us-east-1"

tags = {
  Owner       = "nexTime-frame"
  Environment = "production"
}

sqs_queues = {
  "video-process-command" = {
    queue_name                 = "video-process-command"
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 345600
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 30
    max_receive_count          = 3
    enable_queue_policy        = false
  },
  "video-updated-event" = {
    queue_name                 = "video-updated-event"
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 345600
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 30
    max_receive_count          = 3
    enable_queue_policy        = false
  },
  "video-processed-event" = {
    queue_name                 = "video-processed-event"
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 345600
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 360
    max_receive_count          = 3
    enable_queue_policy        = false
  }
}

ses_email = "framenextime@gmail.com"
# role_arn is now derived dynamically via data.aws_caller_identity in main.tf
s3_bucket_name = "nextime-frame-video-storage"
