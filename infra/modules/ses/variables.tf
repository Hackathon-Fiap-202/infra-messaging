variable "email_address" {
  description = "Email remetente verificado no SES"
  type        = string
}

variable "allowed_principals" {
  description = "ARNs que podem enviar email via SES (ex: role da Lambda)"
  type        = list(string)
}

variable "create_policy" {
  description = "Create SES identity policy"
  type        = bool
  default     = true
}
