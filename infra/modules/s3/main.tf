resource "aws_s3_bucket" "nextime_video" {
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Name = var.bucket_name
  })
}

resource "aws_s3_bucket_versioning" "nextime_video" {
  bucket = aws_s3_bucket.nextime_video.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "nextime_video" {
  bucket = aws_s3_bucket.nextime_video.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_sqs_queue_policy" "allow_s3_events" {
  queue_url = var.sqs_queue_url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = var.sqs_queue_arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.nextime_video.arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "start_process_trigger" {
  bucket = aws_s3_bucket.nextime_video.id

  queue {
    queue_arn     = var.sqs_queue_arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "video-input-storage/start-process/"
    filter_suffix = ".mp4"  # ou o formato do seu vídeo
  }

  depends_on = [aws_sqs_queue_policy.allow_s3_events]
}
