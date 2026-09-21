variable "github_owner" {
  description = "Your GitHub username"
  type        = string
  default     = "tatan461"
}

variable "github_repo" {
  description = "Your GitHub repository name"
  type        = string
  default     = "cloud-resume-ai"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}@96512611/${var.github_repo}@1375208092:*"]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name               = "github-actions-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "github_actions_deploy_policy" {
  name = "github-actions-deploy-policy"
  role = aws_iam_role.github_actions_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CoreServices"
        Effect = "Allow"
        Action = [
          "s3:*",
          "s3vectors:*",
          "lambda:*",
          "apigateway:*",
          "bedrock:*",
          "budgets:*",
          "dynamodb:*",
          "cloudfront:*",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMManagementForProjectRoles"
        Effect = "Allow"
        Action = ["iam:*"]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cloud-resume-ai-*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        ]
      }
    ]
  })
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}
