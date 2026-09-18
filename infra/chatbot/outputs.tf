# infra/chatbot/outputs.tf

output "knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base, used by the chatbot Lambda."
  value       = aws_bedrockagent_knowledge_base.resume_kb.id
}

output "data_source_id" {
  description = "ID of the S3 data source feeding the Knowledge Base."
  value       = aws_bedrockagent_data_source.resume_source.data_source_id
}

output "kb_source_bucket" {
  description = "Name of the S3 bucket storing the raw resume/project context."
  value       = aws_s3_bucket.kb_source.id
}

output "vector_bucket_arn" {
  description = "ARN of the S3 Vectors bucket used as the vector store."
  value       = aws_s3vectors_vector_bucket.kb_vectors.vector_bucket_arn
}

output "guardrail_id" {
  description = "ID of the Bedrock Guardrail applied to chatbot responses."
  value       = aws_bedrock_guardrail.resume_guardrail.guardrail_id
}

output "chatbot_api_endpoint" {
  description = "Invoke URL for the chatbot API. Use this in the frontend widget."
  value       = "${aws_apigatewayv2_api.chatbot_api.api_endpoint}/chat"
}
