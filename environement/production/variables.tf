variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "project_name" {
  type    = string
  default = "ecs-fargate-demo"
}

variable "azs" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "github_org" {
  description = "Your GitHub username, e.g. jamilkhan-me"
  type        = string
}

# This repo name should be same
variable "github_repo" {
  description = "Name of this repo once pushed to GitHub"
  type        = string
  default     = "AWS-terraform-project--2-CICD-pipeline"
}
