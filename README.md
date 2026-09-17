# Cloud Resume Challenge + AI (Bedrock)

Professional portfolio deployed 100% on AWS with Terraform, combining:
- AWS Solutions Architect Associate certification (architecture, security, networking)
- AWS AI Practitioner certification (Bedrock, RAG, Guardrails)

## Architecture

User -> CloudFront (CDN + HTTPS) -> S3 (static site, private bucket with OAC)
                                  -> API Gateway -> Lambda (visit counter) -> DynamoDB
                                  -> API Gateway -> Lambda (AI chatbot) -> Bedrock Knowledge Base (RAG) -> Bedrock Guardrails -> Nova Micro model

## Project phases

- [ ] Phase 1: Static frontend (S3 + CloudFront + ACM + Route 53)
- [ ] Phase 2: Visit counter backend (API Gateway + Lambda + DynamoDB)
- [ ] Phase 3: Full migration to Terraform
- [ ] Phase 4: CI/CD with GitHub Actions (OIDC, no static credentials)
- [ ] Phase 5: AI chatbot with Bedrock Knowledge Base + Guardrails
- [ ] Phase 6: Chat widget on the frontend

## Architecture decisions

- Private S3 bucket + Origin Access Control (OAC): avoids exposing the bucket directly, only CloudFront can read it.
- HTTP API in API Gateway instead of REST API: simpler and cheaper for this use case.
- Amazon Nova Micro model in Bedrock: the most cost-effective option ($0.035 per million input tokens), sufficient for a portfolio RAG chatbot.
- Bedrock Guardrails: prevents the chatbot from answering off-topic questions or leaking sensitive information.
- OIDC authentication in GitHub Actions: no static AWS credentials stored as secrets.

## How to deploy (WSL)

```bash
cd infra/frontend
terraform init
terraform plan
terraform apply
```

## Estimated cost

- S3 + CloudFront + Route53: a few cents/month with low traffic.
- Lambda + API Gateway + DynamoDB: covered by the free tier in most cases.
- Bedrock (Nova Micro): pay-per-token, check the CloudWatch billing alarm configured for this project.

## Author

Portfolio project - Junior Cloud Engineer / AWS Solutions Architect Associate + AI Practitioner.
