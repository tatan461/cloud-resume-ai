# infra/chatbot/variables.tf

variable "project_name" {
  description = "Project name prefix used for naming AWS resources."
  type        = string
  default     = "cloud-resume-ai"
}

variable "aws_region" {
  description = "AWS region where the chatbot infrastructure is deployed."
  type        = string
  default     = "us-east-1"
}

variable "chat_model_id" {
  description = "Bedrock foundation model ID used to generate chatbot responses."
  type        = string
  default     = "amazon.nova-micro-v1:0"
}
