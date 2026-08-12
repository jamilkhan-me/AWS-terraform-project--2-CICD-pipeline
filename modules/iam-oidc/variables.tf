variable "project_name" {
  type = string
}

variable "github_org" {
  description = "Your GitHub username or org, e.g. jamilkhan-me"
  type        = string
}

variable "github_repo" {
  description = "Repository name that's allowed to assume this role"
  type        = string
}

variable "ecr_repository_arn" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}
