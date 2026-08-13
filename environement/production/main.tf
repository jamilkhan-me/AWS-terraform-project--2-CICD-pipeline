module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  azs                  = var.azs
  vpc_cidr             = "10.2.0.0/16"
  public_subnet_cidrs  = ["10.2.0.0/24", "10.2.1.0/24"]
  private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
}

module "alb" {
  source = "../../modules/alb"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  source = "../../modules/ecs"

  project_name          = var.project_name
  aws_region            = var.aws_region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  ecr_repository_url    = module.ecr.repository_url
  desired_count         = 2
}

module "iam_oidc" {
  source = "../../modules/iam-oidc"

  project_name       = var.project_name
  github_org         = var.github_org
  github_repo        = var.github_repo
  ecr_repository_arn = module.ecr.repository_arn
  ecs_cluster_arn    = module.ecs.cluster_name
}
