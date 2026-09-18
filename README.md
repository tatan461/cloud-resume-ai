# Cloud Resume Challenge + AI (Bedrock)

[![Deployment](https://img.shields.io/badge/deployment-github--pages-success)]()
[![IaC](https://img.shields.io/badge/IaC-Terraform-623CE4)]()
[![Cloud](https://img.shields.io/badge/cloud-AWS-FF9900)]()
[![Status](https://img.shields.io/badge/status-in%20progress-yellow)]()

Professional portfolio deployed 100% on AWS with Terraform, combining a high-performance static resume with a conversational AI assistant (RAG) capable of answering questions about my background and projects.

**Author:** Jonathan Ángel González — Junior Cloud Engineer | [AWS Solutions Architect Associate](#) · [AWS AI Practitioner](#)
[LinkedIn](https://linkedin.com/in/jonathan-angel-gonzalez-0543b441a) · [GitHub](https://github.com/tatan461)

---

## Why this project

This repository is my implementation of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/), extended with an Amazon Bedrock-powered chatbot. The goal is to demonstrate, with real and documented infrastructure, the skills behind my **AWS Solutions Architect – Associate** and **AWS AI Practitioner** certifications: serverless architecture design, security, high-availability networking, generative AI, and infrastructure automation.

## Architecture

![Cloud Resume AI Architecture](docs/images/architecture.png)

*Diagram generated with [draw.io](https://app.diagrams.net) using official AWS icons. Editable source: [`docs/diagrams/cloud-resume-ai-architecture.drawio`](docs/diagrams/cloud-resume-ai-architecture.drawio).*

**Flow summary:**

User → CloudFront (CDN + HTTPS) → S3 (static site, private bucket with OAC), which branches into:

- API Gateway → Lambda (visit counter) → DynamoDB
- API Gateway → Lambda (AI chatbot) → Bedrock Knowledge Base (RAG) → Bedrock Guardrails → Amazon Nova Micro model

The entire stack is defined as code and deployed via Terraform, with no resources created manually through the AWS Console.

## Project phases

- [x] **Phase 1** — Static frontend (S3 + CloudFront + ACM + Route 53 / GitHub Pages)
- [ ] **Phase 2** — Visit counter backend (API Gateway + Lambda + DynamoDB)
- [ ] **Phase 3** — Full migration to Terraform
- [ ] **Phase 4** — CI/CD with GitHub Actions (OIDC authentication, no static credentials)
- [ ] **Phase 5** — AI chatbot with Bedrock Knowledge Base + Guardrails
- [ ] **Phase 6** — Chat widget on the frontend

## Architecture decisions

- **Private S3 bucket + Origin Access Control (OAC):** avoids exposing the bucket directly; only CloudFront can read it.
- **HTTP API in API Gateway** instead of REST API: simpler and cheaper for this use case.
- **Amazon Nova Micro model in Bedrock:** the most cost-effective option ($0.035 per million input tokens), sufficient for a portfolio RAG chatbot.
- **Bedrock Guardrails:** prevents the chatbot from answering off-topic questions or leaking sensitive information.
- **OIDC authentication in GitHub Actions:** no static AWS credentials stored as secrets.

## Tech stack

| Category | Technologies |
|---|---|
| Cloud & IaC | AWS (S3, CloudFront, Lambda, API Gateway, DynamoDB, Bedrock, KMS, IAM), Terraform |
| Generative AI | Amazon Bedrock (Nova Micro), Knowledge Base (RAG), Guardrails |
| CI/CD | GitHub Actions, OIDC |
| Languages | Python, HCL |

## How to deploy (WSL/Linux)

```bash
cd infra/frontend
terraform init
terraform plan
terraform apply
```

## Estimated cost

| Component | Approximate cost |
|---|---|
| S3 + CloudFront + Route 53 | A few cents/month with low traffic |
| Lambda + API Gateway + DynamoDB | Covered by the free tier in most cases |
| Bedrock (Nova Micro) | Pay-per-token; CloudWatch billing alarm configured for this project |

## Demo

🔗 Live site: *(add your GitHub Pages link here once published)*

---

*Portfolio project — Junior Cloud Engineer / AWS Solutions Architect Associate + AI Practitioner.*
