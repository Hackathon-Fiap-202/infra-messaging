region = "us-east-1"

tags = {
  Owner = "nexTime-food"
}

sqs_queues = {
  "video-update-queue" = {
    queue_name                 = "video-update-queue"
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 345600
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 30
    max_receive_count          = 3
    enable_queue_policy        = false
  },
  "proccess-video-queue" = {
    queue_name                 = "proccess-video-queue"
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 345600
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 30
    max_receive_count          = 3
    enable_queue_policy        = false
  },
  "video-uploaded-queue" = {
    queue_name                 = "video-uploaded-queue"
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 345600
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 30
    max_receive_count          = 3
    enable_queue_policy        = false
  }
}

ses_email = "framenextime@gmail.com"