# Cloud Resume AI

[![Deploy Infrastructure](https://github.com/tatan461/cloud-resume-ai/actions/workflows/deploy.yml/badge.svg)](https://github.com/tatan461/cloud-resume-ai/actions)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An implementation of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/) extended with a **Bedrock-powered AI assistant** that can answer questions about my background, skills, and experience directly on the resume page.

The entire stack — frontend, backend, and chatbot — is provisioned with **Terraform** and deployed automatically through **GitHub Actions** using **OIDC** (no long-lived AWS credentials stored in CI).

**Live site:** [tatan461.github.io/cloud-resume-ai](https://tatan461.github.io/cloud-resume-ai)

---

## Architecture

```
                        ┌─────────────────────┐
                        │   GitHub Pages       │
                        │   (static frontend)  │
                        └──────────┬───────────┘
                                   │ HTTPS
                                   ▼
                        ┌─────────────────────┐
                        │  Amazon API Gateway  │
                        │   (CORS-restricted)  │
                        └──────────┬───────────┘
                                   │
                                   ▼
                        ┌─────────────────────┐
                        │    AWS Lambda        │
                        │  (chatbot handler)   │
                        └──────────┬───────────┘
                                   │
                 ┌─────────────────┼─────────────────┐
                 ▼                 ▼                 ▼
        ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
        │Amazon Bedrock │  │  Bedrock      │  │  Bedrock      │
        │ (LLM runtime) │  │  Guardrail    │  │  Knowledge Base│
        └──────────────┘  └──────────────┘  └──────┬───────┘
                                                     ▼
                                            ┌──────────────┐
                                            │  S3 Vectors   │
                                            │ (vector store)│
                                            └──────────────┘
```

**Frontend:** static HTML/CSS/JS resume, hosted on GitHub Pages.

**Backend/Chatbot:** API Gateway → Lambda → Amazon Bedrock, grounded with a Knowledge Base backed by **S3 Vectors** (chosen over OpenSearch Serverless specifically to avoid its always-on OCU billing) and protected by a **Bedrock Guardrail** that keeps the assistant on-topic and safe.

**Cost control:** an AWS Budget (`cloud-resume-ai-monthly-budget`, $5/month) tracks actual spend across the whole stack.

---

## Repository Structure

```
cloud-resume-ai/
├── infra/
│   ├── backend/     # Shared Terraform remote state (S3 backend)
│   ├── chatbot/      # Lambda, API Gateway, Bedrock Guardrail & Knowledge Base, Budget
│   └── frontend/     # Static site infra (GitHub Pages config)
├── docs/              # Architecture notes and diagrams
└── .github/workflows/ # CI/CD pipeline (OIDC auth, terraform plan/apply)
```

---

## CI/CD Pipeline

Every push to `main` triggers a GitHub Actions workflow that authenticates to AWS via **OIDC** (no static access keys), runs `terraform plan`, and applies changes automatically:

1. GitHub Actions assumes an IAM role through the OIDC identity provider.
2. Terraform initializes against a **shared remote state** in S3, so local runs and CI runs never drift apart.
3. `terraform plan` → `terraform apply` provisions or updates the Lambda, API Gateway, Bedrock Guardrail (draft + published version), Knowledge Base, S3 Vectors index, and the AWS Budget.
4. On success, the pipeline reports green and the live chatbot is guaranteed to match the code in the repo.

### Hardening applied to the pipeline

Getting this pipeline reliably green required closing several real-world gaps, all fixed and documented here as part of the learning process:

| Issue | Fix |
|---|---|
| Open CORS (`allow_origins = ["*"]`) on API Gateway | Restricted to the exact GitHub Pages origin |
| Hardcoded AWS account ID placeholder in the workflow | Replaced with a GitHub repository variable |
| Outdated OIDC `sub` claim format | Updated to GitHub's numeric-ID claim format (in effect since July 2026) |
| Duplicate IAM roles (one in `backend`, one in `chatbot`) | Consolidated into a single role |
| Overly broad / missing IAM permissions, discovered incrementally | Scoped `iam:*` actions to specific resource ARN prefixes |
| Terraform state not shared between local machine and GitHub Actions | Migrated to a shared S3 remote backend |
| Terraform version mismatch between local and CI | Pinned CI to match the local Terraform version |
| OIDC provider accidentally deleted during a fix | Recreated with a dynamically fetched thumbprint |

---

## AI Assistant Details

- **Model runtime:** Amazon Bedrock.
- **Guardrail:** `cloud-resume-ai-guardrail`, published as version `1` for production use (kept on a `DRAFT` alongside the published version so changes can be tested before rollout). Keeps the assistant on-topic and blocks unsafe or irrelevant content.
- **Knowledge Base:** grounds answers in my actual resume content, using **S3 Vectors** as the vector store instead of OpenSearch Serverless to keep idle cost at zero.
- **Cost posture:** every component (Lambda, API Gateway, Bedrock invocations, S3 Vectors) is pay-per-use; nothing runs 24/7. A $5/month AWS Budget monitors actual spend as a safety net.

> **Note on cost forecasts:** AWS Cost Explorer's forecast can look alarming (in one case it projected ~$200/month) when there are only a few days of near-zero historical spend to model from — this is a known forecasting artifact with short/mostly-zero histories, not real usage. Actual spend is the number that matters, and it has stayed effectively at $0.00.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend hosting | GitHub Pages |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions (OIDC) |
| Compute | AWS Lambda |
| API | Amazon API Gateway |
| AI | Amazon Bedrock (LLM + Guardrails + Knowledge Base) |
| Vector store | Amazon S3 Vectors |
| Cost governance | AWS Budgets |

---

## What This Project Demonstrates

Beyond satisfying the original Cloud Resume Challenge checklist, this project reflects the kind of iterative, real-world troubleshooting a Cloud Engineer does day to day: diagnosing layered failures across CORS, OIDC federation, IAM least-privilege, shared Terraform state, and cost governance — and resolving each one methodically until the pipeline runs clean end to end.

## License

This project is licensed under the [MIT License](LICENSE).
