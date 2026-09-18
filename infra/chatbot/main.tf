# infra/chatbot/main.tf
# Bedrock Knowledge Base (RAG) for the Cloud Resume AI chatbot.
# Data source: resume-context.md uploaded to S3.
# Vector store: Amazon S3 Vectors (cheapest option, no fixed monthly cost).

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}

data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# S3 bucket that stores the raw knowledge (resume-context.md)
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "kb_source" {
  bucket = "${var.project_name}-kb-source-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "kb_source" {
  bucket                  = aws_s3_bucket.kb_source.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "resume_context" {
  bucket       = aws_s3_bucket.kb_source.id
  key          = "resume-context.md"
  source       = "${path.module}/../../docs/data/resume-context.md"
  etag         = filemd5("${path.module}/../../docs/data/resume-context.md")
  content_type = "text/markdown"
}

# ---------------------------------------------------------------------------
# S3 Vectors — vector store for the Knowledge Base
# ---------------------------------------------------------------------------
resource "aws_s3vectors_vector_bucket" "kb_vectors" {
  vector_bucket_name = "${var.project_name}-kb-vectors"
}

resource "aws_s3vectors_index" "kb_index" {
  index_name         = "${var.project_name}-kb-index"
  vector_bucket_name = aws_s3vectors_vector_bucket.kb_vectors.vector_bucket_name
  data_type          = "float32"
  dimension          = 1024
  distance_metric    = "cosine"
}

# ---------------------------------------------------------------------------
# IAM role that Bedrock assumes to read the S3 source and write to S3 Vectors
# ---------------------------------------------------------------------------
resource "aws_iam_role" "bedrock_kb_role" {
  name = "${var.project_name}-bedrock-kb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "bedrock.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "bedrock_kb_policy" {
  name = "${var.project_name}-bedrock-kb-policy"
  role = aws_iam_role.bedrock_kb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3SourceAccess"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.kb_source.arn,
          "${aws_s3_bucket.kb_source.arn}/*"
        ]
      },
      {
        Sid    = "S3VectorsAccess"
        Effect = "Allow"
        Action = [
          "s3vectors:PutVectors",
          "s3vectors:GetVectors",
          "s3vectors:QueryVectors",
          "s3vectors:DeleteVectors",
          "s3vectors:ListVectors"
        ]
        Resource = [
          aws_s3vectors_vector_bucket.kb_vectors.arn,
          aws_s3vectors_index.kb_index.arn
        ]
      },
      {
        Sid      = "BedrockEmbeddingModelAccess"
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel"]
        Resource = "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-embed-text-v2:0"
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# Bedrock Knowledge Base
# ---------------------------------------------------------------------------
resource "aws_bedrockagent_knowledge_base" "resume_kb" {
  name     = "${var.project_name}-knowledge-base"
  role_arn = aws_iam_role.bedrock_kb_role.arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-embed-text-v2:0"
      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = 1024
          embedding_data_type = "FLOAT32"
        }
      }
    }
  }

  storage_configuration {
    type = "S3_VECTORS"
    s3vectors_configuration {
      s3_vector_bucket_arn = aws_s3vectors_vector_bucket.kb_vectors.arn
      vector_index_arn     = aws_s3vectors_index.kb_index.arn
    }
  }

  depends_on = [aws_iam_role_policy.bedrock_kb_policy]
}

resource "aws_bedrockagent_data_source" "resume_source" {
  name              = "${var.project_name}-resume-source"
  knowledge_base_id = aws_bedrockagent_knowledge_base.resume_kb.id

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.kb_source.arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens         = 300
        overlap_percentage = 20
      }
    }
  }

  depends_on = [aws_s3_object.resume_context]
}
