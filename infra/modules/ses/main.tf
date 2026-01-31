resource "aws_ses_email_identity" "this" {
  email = var.email_address
}

data "aws_iam_policy_document" "ses_identity_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.allowed_principals
    }

    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]

    resources = [
      aws_ses_email_identity.this.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = [var.email_address]
    }
  }
}

resource "aws_ses_identity_policy" "this" {
  identity = aws_ses_email_identity.this.arn
  name     = "allow-send-from-lambda"
  policy   = data.aws_iam_policy_document.ses_identity_policy.json
}
