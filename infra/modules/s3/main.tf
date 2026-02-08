resource "aws_s3_bucket" "process_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "process-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "process_bucket" {
  bucket = aws_s3_bucket.process_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "process_bucket" {
  bucket = aws_s3_bucket.process_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_sqs_queue_policy" "allow_s3_events" {
  queue_url = module.sqs.sqs_queue_urls["video-uploaded-event"]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = module.sqs.sqs_queue_arn["video-uploaded-event"]
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.process_bucket.arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "start_process_trigger" {
  bucket = aws_s3_bucket.process_bucket.id

  queue {
    queue_arn = module.sqs.sqs_queue_arn["video-uploaded-event"]
    events    = ["s3:ObjectCreated:*"]

    filter_prefix = "start-process/"
  }

  depends_on = [aws_sqs_queue_policy.allow_s3_events]
}



