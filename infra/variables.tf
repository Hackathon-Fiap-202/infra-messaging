# ========================================
# Core Variables
# ========================================

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "hackhaton"
  }
}

# ========================================
# SQS Variables
# ========================================

variable "sqs_queues" {
  description = "Map of SQS queues to create"
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

# ========================================
# SES Variables
# ========================================

variable "ses_email" {
  description = "Email to verify with SES"
  type        = string
}

# ========================================
# S3 Variables
# ========================================

variable "s3_bucket_name" {
  description = "Single S3 bucket name for all video storage (input and processed)"
  type        = string
  default     = "nextime-frame-video-storage"
}
