data "aws_caller_identity" "current" {}

locals {
  account_id     = data.aws_caller_identity.current.account_id
  user_pool_arn  = "arn:aws:cognito-idp:${var.aws_region}:${local.account_id}:userpool/${var.cognito_user_pool_id}"

  group_name     = "bradesco-readonly-${var.env}"
  policy_name    = "bradesco-cognito-readonly-${var.env}"
}

# -------------------------------
# IAM Policy: Cognito ReadOnly
# -------------------------------
data "aws_iam_policy_document" "cognito_readonly" {
  statement {
    sid     = "AllowReadSinglePool"
    effect  = "Allow"
    actions = [
      "cognito-idp:ListUsers",
      "cognito-idp:AdminGetUser",
      "cognito-idp:DescribeUserPool"
    ]
    resources = [local.user_pool_arn]
  }

  statement {
    sid     = "AllowMinimalUnscopedRead"
    effect  = "Allow"
    actions = [
      "cognito-idp:ListUsersInGroup",
      "cognito-idp:ListGroups",
      "cognito-idp:ListUserPools"
    ]
    resources = ["*"]
  }

  statement {
    sid           = "DenyOtherPools"
    effect        = "Deny"
    actions       = ["cognito-idp:*"]
    not_resources = [local.user_pool_arn]
  }

  statement {
    sid     = "DenyWritesOnTargetPool"
    effect  = "Deny"
    actions = [
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminUpdateUserAttributes",
      "cognito-idp:AdminAddUserToGroup",
      "cognito-idp:AdminRemoveUserFromGroup",
      "cognito-idp:AdminResetUserPassword",
      "cognito-idp:AdminSetUserPassword",
      "cognito-idp:UpdateUserPool",
      "cognito-idp:DeleteUserPool"
    ]
    resources = [local.user_pool_arn]
  }
}

resource "aws_iam_policy" "cognito_readonly" {
  name   = local.policy_name
  policy = data.aws_iam_policy_document.cognito_readonly.json
}

resource "aws_iam_group" "bradesco_readonly" {
  name = local.group_name
}

resource "aws_iam_group_policy_attachment" "attach" {
  group      = aws_iam_group.bradesco_readonly.name
  policy_arn = aws_iam_policy.cognito_readonly.arn
}

# -------------------------------
# Dev-only test IAM user
# -------------------------------
resource "aws_iam_user" "test" {
  count = var.create_test_user ? 1 : 0
  name  = var.test_user_name
}

resource "aws_iam_user_group_membership" "test_membership" {
  count  = var.create_test_user ? 1 : 0
  user   = aws_iam_user.test[0].name
  groups = [aws_iam_group.bradesco_readonly.name]
}

resource "aws_iam_user_login_profile" "test_console" {
  count                   = var.create_test_user ? 1 : 0
  user                    = aws_iam_user.test[0].name
  password_reset_required = true
  pgp_key                 = var.pgp_key_base64 != "" ? var.pgp_key_base64 : null
}

resource "aws_iam_access_key" "test" {
  count = var.create_test_user ? 1 : 0
  user  = aws_iam_user.test[0].name
}
