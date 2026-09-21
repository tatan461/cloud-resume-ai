# infra/chatbot/oidc.tf
# GitHub Actions OIDC provider + IAM role, so CI/CD can run Terraform
# against this AWS account without storing static access keys as secrets.
#
# NOTE: an AWS account can only have ONE OIDC provider per unique URL.
# If you already created "token.actions.githubusercontent.com" as a
# provider elsewhere (e.g. in infra/frontend), remove this
# aws_iam_openid_connect_provider block here and reference the existing
# one instead, to avoid a duplicate-provider error on apply.

variable "github_repo" {
  description = "GitHub repository allowed to assume the CI/CD role, in 'owner/repo' format."
  type        = string
  default     = "tatan461/cloud-resume-ai"
}

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restricts which repo AND which branch/ref can assume this role.
    # Change "main" if your default branch has a different name.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name               = "${var.project_name}-github-actions-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# Scoped permissions for what CI/CD actually needs to do: manage the
# chatbot infra (S3, Lambda, API Gateway, Bedrock, IAM for those roles)
# and sync the static site to its S3 bucket.
resource "aws_iam_role_policy" "github_actions_deploy_policy" {
  name = "${var.project_name}-github-actions-deploy-policy"
  role = aws_iam_role.github_actions_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformStateAndCoreServices"
        Effect = "Allow"
        Action = [
          "s3:*",
          "lambda:*",
          "apigateway:*",
          "bedrock:*",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole",
          "iam:TagRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "s3vectors:*",
          "budgets:*",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role GitHub Actions assumes via OIDC. Use this in the workflow YAML."
  value       = aws_iam_role.github_actions_deploy.arn
}
