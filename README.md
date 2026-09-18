# Cloud Resume Challenge + AI (Bedrock)

[![Deployment](https://img.shields.io/badge/deployment-github--pages-success)]()
[![IaC](https://img.shields.io/badge/IaC-Terraform-623CE4)]()
[![Cloud](https://img.shields.io/badge/cloud-AWS-FF9900)]()
[![Status](https://img.shields.io/badge/status-in%20progress-yellow)]()

Portfolio profesional desplegado 100% en AWS con Terraform, combinando un currículum estático de alto rendimiento con un asistente de IA conversacional (RAG) capaz de responder preguntas sobre mi trayectoria y proyectos.

**Autor:** Jonathan Ángel González — Junior Cloud Engineer | [AWS Solutions Architect Associate](#) · [AWS AI Practitioner](#)
[LinkedIn](https://linkedin.com/in/jonathan-angel-gonzalez-0543b441a) · [GitHub](https://github.com/tatan461)

---

## Por qué este proyecto

Este repositorio es mi implementación del [Cloud Resume Challenge](https://cloudresumechallenge.dev/), extendida con un chatbot basado en Amazon Bedrock. El objetivo es demostrar, con infraestructura real y documentada, las competencias detrás de mis certificaciones **AWS Solutions Architect – Associate** y **AWS AI Practitioner**: diseño de arquitecturas serverless, seguridad, redes de alta disponibilidad, IA generativa y automatización con IaC.

## Arquitectura

```
Usuario
  │
  ▼
CloudFront (CDN + HTTPS)
  │
  ▼
S3 (sitio estático, bucket privado con OAC)
  │
  ├──► API Gateway ─► Lambda (contador de visitas) ─► DynamoDB
  │
  └──► API Gateway ─► Lambda (chatbot IA)
                          │
                          ▼
                Bedrock Knowledge Base (RAG)
                          │
                          ▼
                Bedrock Guardrails ─► Modelo Amazon Nova Micro
```

Todo el stack se define como código y se despliega vía Terraform, sin recursos creados manualmente en la consola de AWS.

## Fases del proyecto

- [x] **Fase 1** — Frontend estático (S3 + CloudFront + ACM + Route 53 / GitHub Pages)
- [ ] **Fase 2** — Backend del contador de visitas (API Gateway + Lambda + DynamoDB)
- [ ] **Fase 3** — Migración completa a Terraform
- [ ] **Fase 4** — CI/CD con GitHub Actions (autenticación OIDC, sin credenciales estáticas)
- [ ] **Fase 5** — Chatbot de IA con Bedrock Knowledge Base + Guardrails
- [ ] **Fase 6** — Widget de chat integrado en el frontend

## Decisiones de arquitectura

- **Bucket S3 privado + Origin Access Control (OAC):** evita exponer el bucket directamente; solo CloudFront puede leerlo.
- **HTTP API en API Gateway** en lugar de REST API: más simple y económica para este caso de uso.
- **Modelo Amazon Nova Micro en Bedrock:** la opción más rentable ($0.035 por millón de tokens de entrada), suficiente para un chatbot RAG de portfolio.
- **Bedrock Guardrails:** evita que el chatbot responda preguntas fuera de contexto o filtre información sensible.
- **Autenticación OIDC en GitHub Actions:** sin credenciales AWS estáticas almacenadas como secrets.

## Stack técnico

| Categoría | Tecnologías |
|---|---|
| Cloud & IaC | AWS (S3, CloudFront, Lambda, API Gateway, DynamoDB, Bedrock, KMS, IAM), Terraform |
| IA generativa | Amazon Bedrock (Nova Micro), Knowledge Base (RAG), Guardrails |
| CI/CD | GitHub Actions, OIDC |
| Lenguajes | Python, HCL |

## Cómo desplegar (WSL/Linux)

```bash
cd infra/frontend
terraform init
terraform plan
terraform apply
```

## Coste estimado

| Componente | Coste aproximado |
|---|---|
| S3 + CloudFront + Route 53 | Unos pocos centavos al mes con tráfico bajo |
| Lambda + API Gateway + DynamoDB | Cubierto por la capa gratuita en la mayoría de casos |
| Bedrock (Nova Micro) | Pago por token; alarma de CloudWatch Billing configurada para este proyecto |

## Demo

🔗 Sitio en vivo: *(añade aquí el enlace a tu GitHub Pages una vez publicado)*

---

*Proyecto de portfolio — Junior Cloud Engineer / AWS Solutions Architect Associate + AI Practitioner.*
