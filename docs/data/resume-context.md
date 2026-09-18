# Jonathan Ángel González — Professional Profile

## Summary

Jonathan Ángel González is a Junior Cloud Engineer based in Oviedo, Asturias, Spain, focused on cloud infrastructure automation and serverless architectures. He holds the AWS Certified Solutions Architect – Associate and AWS Certified AI Practitioner certifications. He has practical, hands-on experience building modular Infrastructure as Code (IaC) with Terraform, designing highly available Multi-AZ network architectures, implementing security with KMS, and integrating generative AI services (Amazon Bedrock) with FinOps telemetry. He is currently seeking his first professional opportunity as a Cloud / DevOps Engineer.

Contact: jonathan.angel.tech@gmail.com | LinkedIn: linkedin.com/in/jonathan-angel-gonzalez-0543b441a | GitHub: github.com/tatan461

## Certifications

- AWS Certified AI Practitioner — Amazon Web Services (2026)
- AWS Certified Solutions Architect – Associate — Amazon Web Services (2026)
- EF SET English Certificate — C1 Advanced (2026)

## Projects

### Cloud Resume Challenge + AI (Bedrock)
A professional portfolio project combining a resume website with an AI-powered chatbot. The frontend is deployed via GitHub Pages. The visit-counter backend is fully live on AWS: an API Gateway HTTP endpoint triggers a Lambda function written in Python, which reads and increments a counter stored in DynamoDB. The entire backend (Lambda, DynamoDB, API Gateway, and the IAM OIDC trust relationship) is provisioned as code with Terraform and deployed automatically through a GitHub Actions CI/CD pipeline authenticated via OIDC, with no static AWS credentials stored as secrets. The project also includes an in-progress AI chatbot built on Amazon Bedrock, using a Knowledge Base (RAG) fed with this resume and project data, Bedrock Guardrails to keep responses on-topic, and the Amazon Nova Micro model to generate answers about Jonathan's background and projects.

### AWS Bedrock Serverless API & FinOps Cost Tracker
Designed a serverless REST API on AWS to process prompts using Amazon Bedrock (Nova Micro model). Implemented a FinOps telemetry system that calculates token consumption, latency, and cost in USD in real time, logging the data to DynamoDB. Provisioned 100% of the infrastructure as modular Infrastructure as Code using Terraform. (2026)

### AWS High-Availability Multi-AZ Compute Stack
Deployed a fault-tolerant Multi-AZ VPC architecture with public and private subnets. Configured an Application Load Balancer and Auto Scaling using cost-optimized AWS Graviton (ARM64) instances. Implemented a CI/CD pipeline with GitHub Actions for HCL syntax validation and automatic formatting. (2026)

### AWS 3-Tier Event-Driven Serverless Application
Designed a decoupled 3-tier architecture (S3, API Gateway, AWS Lambda in Python, and DynamoDB On-Demand). Applied least-privilege (PoLP) IAM policies with role-restricted access. Automated the full deployment of components using reusable Terraform templates. (2026)

### AWS Enterprise Security & Core Governance Boundary
Created centralized encryption boundaries using Customer Managed Keys (KMS) with automatic rotation. Centralized log storage in S3 and configured real-time CloudWatch/SNS alerts for authorization errors. Automated security policy and IAM role compliance using Terraform modules. (2026)

## Technical Skills

- **AWS & Cloud Infrastructure:** AWS VPC, EC2, S3, IAM, Lambda, API Gateway, DynamoDB, KMS, CloudFront, Route 53, Amazon Bedrock, Terraform, CloudWatch
- **Security & Governance:** IAM Roles & Policies, Security Groups, NACLs, Least Privilege, OIDC authentication
- **Networking & Systems:** Linux (Ubuntu), TCP/IP, Subnetting, DNS, SSH, Troubleshooting
- **DevOps & Tools:** Git, GitHub, GitHub Actions, Bash Scripting, AWS CLI, Python

## Professional Experience

### Hardware Support and Equipment Repair Technician (2017 – 2023, Oviedo, Spain)
Diagnosed and repaired hardware components in computers and mobile devices. Provided in-person and remote customer technical support.

### Home Automation and Systems Specialist Technician, Ingenium SL (2024 – present, Oviedo, Spain)
Installed, integrated, diagnosed, and maintained automation, control, and local network systems. Resolved technical issues in local networks, communications, and hardware equipment. Developed local scripts to optimize testing and technical support for devices.

## Education

Vocational Training (Grado Medio) in Microcomputer Systems and Networks, IES Nº1, Gijón, Asturias, Spain (2020 – 2022). Covered basic Windows/Linux systems administration, local network setup, and user technical support.

## Languages

- Spanish — Native
- English — Advanced (C1)

## Career goal

Jonathan is actively looking for his first professional role as a Junior Cloud / DevOps Engineer, where he can apply his AWS certifications and hands-on Terraform/IaC experience in a production environment.
