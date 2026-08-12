output "github_actions_role_arn" {
  description = "Paste this into your GitHub Actions workflow's role-to-assume field"
  value       = aws_iam_role.github_actions.arn
}
