
<h1 align="center">Cloud Resume Challenge + AI (Bedrock)</h1>
<p align="center">
  <a href="https://aws.amazon.com/">
    <img src="https://img.shields.io/badge/Cloud-AWS-232F3E?style=flat-square&logo=amazonaws&logoColor=FF9900" alt="AWS">
  </a>
  <a href="https://registry.terraform.io/">
    <img src="https://img.shields.io/badge/IaC-Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white" alt="Terraform">
  </a>
  <a href="https://github.com/tatan461/cloud-resume-ai/actions">
    <img src="https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-24292F?style=flat-square&logo=githubactions&logoColor=2088FF" alt="CI/CD: GitHub Actions">
  </a>
</p>

<p align="center">
  <a href="https://www.credly.com/badges/acb43683-5fc4-49c8-821f-7a49d90f2c74">
    <img src="https://img.shields.io/badge/AWS-Solutions%20Architect%20Associate-232F3E?style=flat-square&logo=amazonaws&logoColor=FF9900" alt="AWS Solutions Architect Associate">
  </a>
  <a href="https://www.credly.com/badges/4bea0010-dd3b-4433-be2c-d2b46f1915d0">
    <img src="https://img.shields.io/badge/AWS-AI%20Practitioner-232F3E?style=flat-square&logo=amazonaws&logoColor=FF9900" alt="AWS Certified AI Practitioner">
  </a>
  <a href="https://www.linkedin.com/in/jonathan-angel-gonzalez-0543b441a/">
    <img src="https://img.shields.io/badge/LinkedIn-Profile-0A66C2?style=flat-square&logo=linkedin&logoColor=white" alt="LinkedIn profile">
  </a>
</p>

> A serverless Cloud Resume Challenge with an Amazon Bedrock-powered RAG chatbot, Terraform-managed infrastructure, and automated CI/CD through GitHub Actions.

<p align="center">
  <a href="https://github.com/tatan461/cloud-resume-ai">
    <img src="https://img.shields.io/badge/View-Repository-24292F?style=flat-square&logo=github&logoColor=white" alt="View repository">
  </a>
  <a href="https://tatan461.github.io/cloud-resume-ai/">
    <img src="https://img.shields.io/badge/Live-Demo-16A34A?style=flat-square&logo=googlechrome&logoColor=white" alt="Live demo">
  </a>
</p>

## Overview

This project is my implementation of the Cloud Resume Challenge, extended with an AI assistant grounded in project-specific information through Amazon Bedrock and RAG.

## See it in action

The chat widget is backed by a **real Bedrock RAG pipeline**, not scripted responses. It answers questions about my background, certifications, and project architecture, while filtering off-topic queries via **Bedrock Guardrails**.

**Sample Interaction:**

> **User:** *"What AWS experience does Jonathan have?"*  
> **Assistant:** *"Jonathan holds the AWS Solutions Architect – Associate and AWS AI Practitioner certifications, and built this entire project's infrastructure — S3, CloudFront, Lambda, API Gateway, DynamoDB, and Bedrock — as code with Terraform, deployed through a GitHub Actions pipeline authenticated via OIDC."*

**Try asking:** *"How was the chatbot deployed?"*, *"What certifications does Jonathan have?"*, or *"Describe the architecture."*

---

## Architecture

<img src="docs/images/architecture.png" alt="AWS architecture diagram: CloudFront distributing a private S3 static site, branching into a visit-counter path (API Gateway, Lambda, DynamoDB) and an AI chatbot path (rate-limited API Gateway, Lambda, Bedrock Guardrails, Bedrock Knowledge Base with S3 Vectors, and the Amazon Nova Micro model)" width="100%">

## Flow Summary

- **Frontend:** User → CloudFront → private S3 bucket
- **Visitor counter:** API Gateway → Lambda → DynamoDB
- **AI chatbot:** API Gateway → Lambda → Bedrock Guardrails → Bedrock Knowledge Base → Amazon Nova Micro

All infrastructure is defined with Terraform and deployed through GitHub Actions using AWS OIDC authentication. No long-lived AWS credentials are stored in the repository.

## Architecture Decisions

- **Private S3 bucket + OAC:** CloudFront is the only service allowed to read the static website.
- **Serverless backend:** API Gateway, Lambda, and DynamoDB minimize operational overhead.
- **Amazon Nova Micro:** A cost-efficient model suitable for a portfolio RAG chatbot.
- **Bedrock Guardrails:** Filters off-topic requests and helps prevent unsafe responses.
- **GitHub Actions with OIDC:** Enables secure deployments without long-lived AWS credentials.
- **API Gateway throttling:** Controls chatbot traffic and keeps token usage predictable.
- **Terraform:** Defines the infrastructure reproducibly and makes the environment easier to review.

## Tech Stack

| Category | Technologies |
|---|---|
| Cloud | AWS, Amazon S3, CloudFront, Lambda, API Gateway, DynamoDB |
| Generative AI | Amazon Bedrock, Knowledge Bases, Guardrails, Amazon Nova Micro |
| Infrastructure | Terraform |
| CI/CD | GitHub Actions, AWS OIDC |
| Application | Python, HTML, CSS, JavaScript |
| Configuration | HCL |

## Deployment

**Requirements:** AWS CLI, Terraform, WSL/Linux, and an AWS account with the required IAM permissions.

### Local deployment with WSL/Linux

The project is organized into three Terraform modules deployed in this order:

```text
infra/backend
infra/frontend
infra/chatbot
```

Run the complete deployment from the repository root:

```bash
for module in backend frontend chatbot; do
  echo "Deploying infra/$module"
  cd "infra/$module"
  terraform init
  terraform validate
  terraform plan
  terraform apply
  cd ../..
done
```

The GitHub Actions workflow can also deploy the infrastructure automatically using AWS OIDC authentication.

Local deployment requires AWS CLI credentials, Terraform, and sufficient IAM permissions for S3, CloudFront, Lambda, API Gateway, DynamoDB, and Amazon Bedrock.

> Do not commit AWS access keys, tokens, or other secrets to the repository.

## Estimated Cost

The current public frontend is hosted on GitHub Pages. S3 and CloudFront represent the AWS deployment architecture managed by Terraform.

| Component | Approximate cost |
|---|---|
| GitHub Pages | $0 for the current frontend hosting |
| S3 + CloudFront | A few cents per month with low traffic |
| Route 53 | Additional DNS cost if a custom domain is enabled |
| Lambda + API Gateway + DynamoDB | Usually covered by the AWS Free Tier at low traffic; verify current limits |
| Amazon Bedrock — Nova Micro | Pay-per-use; cost depends on input and output tokens |

Actual costs depend on traffic, AWS Region, request volume, storage, and Bedrock usage. AWS Budgets and CloudWatch billing alerts are configured for cost monitoring.

## Lessons Learned

- Cost awareness should be considered from the beginning of a cloud project.
- Terraform improves reproducibility but requires careful state management.
- GitHub Actions OIDC is safer than storing long-lived AWS credentials.
- RAG and Bedrock Guardrails improve the reliability and scope control of a public AI assistant.


## Roadmap

The core Cloud Resume Challenge is complete end-to-end: static frontend, visit counter, full Terraform migration, OIDC-based CI/CD, and an AI chatbot backed by Amazon Bedrock with Guardrails, RAG, and API Gateway rate limiting.

Possible next steps if the project keeps evolving:

- CloudWatch alarms for chatbot latency and error rate.
- Automated chatbot tests inside the CI/CD pipeline.
- SQS-based async processing for higher chatbot throughput.
- A Kubernetes-based project to round out the cloud/DevOps skill set.


> Portfolio project — Junior Cloud Engineer / AWS Solutions Architect Associate + AI Practitioner.
