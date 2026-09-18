# Cloud Resume Challenge + AI (Bedrock)

[![Deployment](https://img.shields.io/badge/deployment-github--pages-success)]()
[![IaC](https://img.shields.io/badge/IaC-Terraform-623CE4)]()
[![Cloud](https://img.shields.io/badge/cloud-AWS-FF9900)]()
[![Status](https://img.shields.io/badge/status-in%20progress-yellow)]()
[![License](https://img.shields.io/badge/license-MIT-blue)]()

Professional portfolio combining a high-performance static resume with a conversational AI assistant (RAG) capable of answering questions about my background and projects. The full AWS architecture is designed and provisioned as code with Terraform; the frontend is currently deployed via GitHub Pages while the serverless backend phases are built out.

**Author:** Jonathan Ángel González — Junior Cloud Engineer | [AWS Solutions Architect Associate](https://www.credly.com/badges/acb43683-5fc4-49c8-821f-7a49d90f2c74) · [AWS AI Practitioner](https://www.credly.com/badges/4bea0010-dd3b-4433-be2c-d2b46f1915d0)
[LinkedIn](https://linkedin.com/in/jonathan-angel-gonzalez-0543b441a) · [GitHub](https://github.com/tatan461)

---

## Why this project

This repository is my implementation of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/), extended with an Amazon Bedrock-powered chatbot. The goal is to demonstrate, with real and documented infrastructure, the skills behind my **[AWS Solutions Architect – Associate](https://www.credly.com/badges/acb43683-5fc4-49c8-821f-7a49d90f2c74)** and **[AWS AI Practitioner](https://www.credly.com/badges/4bea0010-dd3b-4433-be2c-d2b46f1915d0)** certifications: serverless architecture design, security, high-availability networking, generative AI, and infrastructure automation.

## Live demo

🔗 **Site:** [tatan461.github.io/cloud-resume-ai](https://tatan461.github.io/cloud-resume-ai/)

<!-- Optional: add a screenshot of the homepage once available
![Homepage screenshot](docs/images/homepage.png)
-->

## Architecture

<img src="docs/images/architecture.png" alt="Cloud Resume AI Architecture" width="100%">

**Flow summary:**

User → CloudFront (CDN + HTTPS) → S3 (static site, private bucket with OAC), which branches into:

- API Gateway → Lambda (visit counter) → DynamoDB
- API Gateway → Lambda (AI chatbot) → Bedrock Knowledge Base (RAG) → Bedrock Guardrails → Amazon Nova Micro model

The entire backend stack is defined as code and designed to deploy via Terraform, with no resources created manually through the AWS Console.

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
- **OIDC authentication in GitHub Actions:** no static AWS credentials stored as secrets (planned for Phase 4).
- **GitHub Pages for the current frontend:** zero cost and zero billing risk while earlier phases are still in progress; the S3 + CloudFront + Route 53 stack stays ready in Terraform for when a custom domain is worth the ~$1–2/month it adds.

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
| GitHub Pages (current frontend) | $0 |
| S3 + CloudFront + Route 53 (if/when adopted) | A few cents/month with low traffic |
| Lambda + API Gateway + DynamoDB | Covered by the free tier in most cases |
| Bedrock (Nova Micro) | Pay-per-token; CloudWatch billing alarm configured for this project |

## Lessons learned

- **Cost-consciousness matters as much as architecture.** Before deploying anything, I compared the real monthly cost of S3 + CloudFront + Route 53 against GitHub Pages. The AWS stack is cheap (roughly $1–2/month), but as a job-seeking junior engineer, starting at $0 with GitHub Pages removed any billing risk while I keep building — the Terraform module for the AWS stack stays ready to apply later.
- **Domain registrar pricing has hidden traps.** Comparing registrars taught me that "cheap first year" prices (Namecheap, GoDaddy) often hide renewal costs 2–3x higher; flat-rate registrars like Cloudflare or Porkbun are cheaper over a 5-year horizon even if the first-year price looks less attractive.
- **Diagrams-as-code beats ASCII art.** Switching the architecture diagram from a plain-text flow to a `.drawio` file with official AWS icons made the README noticeably more professional and easier to scan for recruiters.

## Roadmap

This project is part of a broader portfolio. Next up: an AI chatbot backend (Amazon Bedrock + Lambda + API Gateway) to power the assistant referenced above, followed by a Kubernetes-based project to round out the cloud/DevOps skill set.

---

*Portfolio project — Junior Cloud Engineer / AWS Solutions Architect Associate + AI Practitioner.*
