output "group_name" {
  value       = aws_iam_group.bradesco_readonly.name
  description = "IAM group to which users should be added"
}

output "policy_arn" {
  value       = aws_iam_policy.cognito_readonly.arn
  description = "Read-only policy ARN"
}

output "cognito_user_pool_arn" {
  value       = local.user_pool_arn
  description = "Scoped Cognito User Pool ARN"
}

output "test_user_name" {
  value       = try(aws_iam_user.test[0].name, null)
  description = "Dev test user (null in prod)"
}

output "test_user_encrypted_password" {
  value       = try(aws_iam_user_login_profile.test_console[0].encrypted_password, null)
  sensitive   = true
  description = "PGP-encrypted initial console password (decrypt with your private key)"
}

output "test_user_access_key_id" {
  value       = try(aws_iam_access_key.test[0].id, null)
  sensitive   = true
}

output "test_user_secret_access_key" {
  value       = try(aws_iam_access_key.test[0].secret, null)
  sensitive   = true
}

# Outputs for managed Bradesco users
output "bradesco_users" {
  value = {
    for key, user in aws_iam_user.bradesco_users :
    key => {
      username = user.name
      arn      = user.arn
      email    = user.tags["Email"]
    }
  }
  description = "Map of all Bradesco team members"
}

output "bradesco_users_encrypted_passwords" {
  value = {
    for key, profile in aws_iam_user_login_profile.bradesco_users_console :
    key => profile.encrypted_password
  }
  sensitive   = true
  description = "Encrypted passwords for Bradesco users (decrypt with PGP key)"
}

output "total_bradesco_users" {
  value       = length(aws_iam_user.bradesco_users)
  description = "Total number of Bradesco users created"
}
