# Deployment guide

From zero to a working GitHub Actions → ECR → ECS Fargate pipeline,
region **eu-north-1 (Stockholm)**.

## Prerequisites

- Terraform >= 1.5.0, AWS CLI configured (`aws sts get-caller-identity` should work)
- Docker installed locally (for testing the image before pushing)
- A GitHub account, and this project pushed to a repo you control

## Step 1 — Configure the backend

If you already have an S3 bucket + DynamoDB table from your other
Terraform project, you can reuse them — just make sure the `key` in
`terraform/environments/prod/backend.tf` is unique
(`ecs-fargate-cicd/prod/terraform.tfstate`, already set). Otherwise
create a new bucket/table following the same steps as the 3-tier
project's deployment guide.

Fill in `bucket` and `dynamodb_table` in
`terraform/environments/prod/backend.tf`.

## Step 2 — Set your GitHub details

Open `terraform/environments/prod/variables.tf` (or create a
`terraform.tfvars`) and set:

```hcl
github_org  = "jamilkhan-me"       # your GitHub username
github_repo = "ecs-fargate-cicd"   # this repo's name once pushed
```

The IAM OIDC trust policy is scoped to exactly this `org/repo` on the
`main` branch — no other repository can assume the deploy role.

## Step 3 — Provision the infrastructure

```bash
cd terraform/environments/prod
terraform init
terraform plan
terraform apply
```

This creates the VPC, ECR repo, ALB, ECS cluster + service (with a
placeholder task that will fail health checks until a real image
exists — that's expected at this point), and the IAM OIDC role.

Grab two outputs you'll need next:

```bash
terraform output ecr_repository_url
terraform output github_actions_role_arn
```

## Step 4 — Add the GitHub Actions secret

In your GitHub repo: **Settings → Secrets and variables → Actions → New
repository secret**.

- Name: `AWS_GITHUB_ACTIONS_ROLE_ARN`
- Value: the `github_actions_role_arn` output from Step 3

This is the only "secret" involved — it's a role ARN, not an access
key. GitHub Actions exchanges a short-lived OIDC token for temporary
AWS credentials at run time; nothing long-lived is stored anywhere.

## Step 5 — Push to trigger the pipeline

```bash
git add .
git commit -m "Initial commit - trigger pipeline"
git push origin main
```

Go to your repo's **Actions** tab and watch the workflow run:
1. Assumes the AWS role via OIDC
2. Logs into ECR
3. Builds and pushes the Docker image
4. Registers a new ECS task definition revision
5. Updates the ECS service and waits for it to stabilize

## Step 6 — Verify it worked

```bash
cd terraform/environments/prod
terraform output alb_dns_name
```

Open that URL — you should see the JSON response from the sample app
(`{"message":"Hello from ECS Fargate!", ...}`). Try `/health` too, it
should return `OK`.

Check ECS Console → Clusters → your cluster → Service → Tasks: both
tasks should be `RUNNING` with the ALB target group showing them
`healthy`.

## Step 7 — Make a change and watch it redeploy

Edit `app/index.js` (change the message text), commit, push. Watch the
Actions tab — a new image builds, pushes, and the ECS service rolls out
the update with zero manual AWS console interaction. This is the
"proof of pipeline" moment to screenshot for your portfolio.

## Step 8 — Tear down

```bash
cd terraform/environments/prod
terraform destroy
```

This removes everything except the ECR repository's images if you want
to keep a record — delete the ECR repo separately if you want a fully
clean account.

## Troubleshooting common errors

| Error | Likely cause | Fix |
|---|---|---|
| GitHub Actions: `Not authorized to perform sts:AssumeRoleWithWebIdentity` | `github_org`/`github_repo` in Terraform doesn't exactly match your actual repo, or you pushed to a branch other than `main` | Check the trust policy's `sub` condition matches `repo:<org>/<repo>:ref:refs/heads/main` exactly |
| ECS tasks stuck `PENDING` or cycling | Task can't pull the image or reach ECR/CloudWatch (no NAT route) | Confirm the NAT Gateway exists and the private subnet's route table points to it |
| ALB shows 0 healthy targets after first `terraform apply` | Expected — no image has been pushed yet | Push to `main` to trigger the pipeline and deploy a real image |
| `docker build` fails in Actions but works locally | `.dockerignore` missing, or `node_modules` committed and stale | Add a `.dockerignore` excluding `node_modules` |
| `Error: error creating IAM OIDC Provider ... EntityAlreadyExists` | You already have a GitHub OIDC provider from another project in this AWS account | Remove the `aws_iam_openid_connect_provider` resource from `modules/iam-oidc/main.tf` and reference the existing provider ARN instead (OIDC providers are account-wide, not per-project) |

If you hit something not listed here, paste the exact error and we'll
debug it together.
