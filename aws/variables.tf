variable "env" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the Cognito User Pool exists"
  type        = string
  default     = "us-east-2"
}

variable "cognito_user_pool_id" {
  description = "Target Cognito User Pool ID (e.g., us-east-2_AbCd12345)"
  type        = string
}

variable "create_test_user" {
  description = "Whether to create the dev test IAM user (console + programmatic). Set true only in dev."
  type        = bool
  default     = false
}

variable "test_user_name" {
  description = "Dev test IAM username (only used when create_test_user = true)"
  type        = string
  default     = "bradesco.test"
}

variable "pgp_key_base64" {
  description = "Base64-encoded PGP public key to encrypt the initial console password (recommended). Leave empty to skip."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "manage_users" {
  description = "Whether to manage Bradesco team users via Terraform. Set true to create all users."
  type        = bool
  default     = false
}
