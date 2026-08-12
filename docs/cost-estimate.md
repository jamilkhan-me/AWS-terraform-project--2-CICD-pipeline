# Cost estimate

Region: eu-north-1 (Stockholm). Prices are approximate on-demand rates
and can change — always confirm with the
[AWS Pricing Calculator](https://calculator.aws) before relying on
these numbers.

## As deployed by this project (demo-sized)

| Resource | Configuration | Approx. cost |
|---|---|---|
| Fargate tasks | 2x, 0.25 vCPU / 512MB | ~$9/month |
| NAT Gateway | 1x, single-AZ | ~$32/month + ~$0.045/GB processed |
| Application Load Balancer | 1x ALB + LCU usage | ~$17/month + LCU charges |
| ECR storage | A few images, lifecycle-limited to last 10 | ~$0.10/GB/month, usually under $1 |
| CloudWatch Logs | 7-day retention | Usually under $1/month at low volume |
| **Total (idle, low traffic)** | | **~$59-62/month** |

That's the cost if you leave it running 24/7 for a month. For a
portfolio project, you won't — see below.

## What actually costs money for a portfolio project

If you deploy it, push a commit to trigger the pipeline, demo it for an
hour, then `terraform destroy`:

| Item | Cost |
|---|---|
| ~2 hours of running infra (Fargate + NAT + ALB) | ~$0.20-0.30 |
| GitHub Actions minutes | Free (public repos get unlimited minutes; private repos get 2,000 free/month) |
| One-time S3 bucket + DynamoDB table for state | Effectively $0 if reused from your other Terraform project |

**Realistic total to build, demo, and tear down this project multiple times: under $3.**

## The two things that cost money even when "idle"

1. **NAT Gateway** — billed per hour it exists, regardless of traffic (~$0.045/hr). Fargate tasks in private subnets need this for outbound internet access (pulling the image from ECR, unless you add VPC endpoints instead — see below).
2. **ALB** — billed per hour it exists (~$0.023/hr) plus per LCU-hour of actual traffic.

Fargate itself is genuinely cheap at this scale — 2 tasks at 0.25 vCPU/512MB round to just a few dollars a month.

## Cost-reduction options

- Drop `desired_count` to 1 for a pure demo (already easy to change in `terraform.tfvars`).
- Replace the NAT Gateway with **VPC endpoints** for ECR and CloudWatch Logs if you want to eliminate the NAT Gateway cost entirely — more setup complexity, but a good "I optimized this further" talking point for interviews.
- **Run `terraform destroy` as soon as you've captured your screenshots and pipeline run.** This is the single biggest lever, same as the other project.

## For your CV / interview talking point

*"I used Fargate instead of EC2/ASG for this pipeline specifically because it removes the need to manage or patch underlying instances, and configured the CI/CD pipeline with OIDC-based keyless AWS authentication instead of long-lived access keys, which is the current AWS-recommended security practice for GitHub Actions."*
