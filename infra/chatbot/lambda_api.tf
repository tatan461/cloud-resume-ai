# infra/chatbot/lambda_api.tf
# Chatbot Lambda + HTTP API Gateway, wired to the Knowledge Base + Guardrail.

data "archive_file" "chatbot_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/chatbot.py"
  output_path = "${path.module}/lambda/chatbot.zip"
}

resource "aws_iam_role" "chatbot_lambda_role" {
  name = "${var.project_name}-chatbot-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "chatbot_lambda_basic_logs" {
  role       = aws_iam_role.chatbot_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "chatbot_lambda_bedrock_policy" {
  name = "${var.project_name}-chatbot-lambda-bedrock-policy"
  role = aws_iam_role.chatbot_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "BedrockRetrieveAndGenerate"
        Effect   = "Allow"
        Action   = ["bedrock:RetrieveAndGenerate", "bedrock:Retrieve"]
        Resource = aws_bedrockagent_knowledge_base.resume_kb.arn
      },
      {
        Sid      = "BedrockInvokeModel"
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel"]
        Resource = "arn:aws:bedrock:${var.aws_region}::foundation-model/${var.chat_model_id}"
      },
      {
        Sid      = "BedrockGuardrail"
        Effect   = "Allow"
        Action   = ["bedrock:ApplyGuardrail"]
        Resource = aws_bedrock_guardrail.resume_guardrail.guardrail_arn
      }
    ]
  })
}

resource "aws_lambda_function" "chatbot" {
  function_name    = "${var.project_name}-chatbot"
  role             = aws_iam_role.chatbot_lambda_role.arn
  handler          = "chatbot.lambda_handler"
  runtime          = "python3.13"
  timeout          = 30
  memory_size      = 256
  filename         = data.archive_file.chatbot_zip.output_path
  source_code_hash = data.archive_file.chatbot_zip.output_base64sha256

  environment {
    variables = {
      KNOWLEDGE_BASE_ID  = aws_bedrockagent_knowledge_base.resume_kb.id
      MODEL_ARN          = "arn:aws:bedrock:${var.aws_region}::foundation-model/${var.chat_model_id}"
      GUARDRAIL_ID       = aws_bedrock_guardrail.resume_guardrail.guardrail_id
      GUARDRAIL_VERSION  = aws_bedrock_guardrail_version.resume_guardrail_version.version
    }
  }
}

resource "aws_apigatewayv2_api" "chatbot_api" {
  name          = "${var.project_name}-chatbot-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["OPTIONS", "POST"]
    allow_headers = ["Content-Type"]
  }
}

resource "aws_apigatewayv2_integration" "chatbot_integration" {
  api_id                 = aws_apigatewayv2_api.chatbot_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.chatbot.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "chatbot_route" {
  api_id    = aws_apigatewayv2_api.chatbot_api.id
  route_key = "POST /chat"
  target    = "integrations/${aws_apigatewayv2_integration.chatbot_integration.id}"
}

resource "aws_apigatewayv2_stage" "chatbot_stage" {
  api_id      = aws_apigatewayv2_api.chatbot_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = 2
    throttling_burst_limit = 5
  }
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.chatbot_api.execution_arn}/*/*"
}
