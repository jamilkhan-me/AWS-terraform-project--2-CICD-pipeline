output "alb_dns_name" {
  description = "Open this URL to see the deployed app"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "Paste into your GitHub Actions workflow / docker push commands"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "github_actions_role_arn" {
  description = "Paste into your GitHub Actions workflow's role-to-assume field"
  value       = module.iam_oidc.github_actions_role_arn
}
