import json
import os
import boto3

bedrock_agent_runtime = boto3.client("bedrock-agent-runtime")

KNOWLEDGE_BASE_ID = os.environ["KNOWLEDGE_BASE_ID"]
MODEL_ARN = os.environ["MODEL_ARN"]
GUARDRAIL_ID = os.environ["GUARDRAIL_ID"]
GUARDRAIL_VERSION = os.environ.get("GUARDRAIL_VERSION", "1")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "OPTIONS,POST",
}

PROMPT_TEMPLATE = """You are Jonathan's resume assistant, answering recruiters on his portfolio site.
Use only the search results below to answer the question.
Keep your answer short and conversational: 2 to 4 sentences, no headers, no numbered lists, no bullet points.
If the search results don't contain the answer, say you don't have that information and suggest contacting Jonathan directly.

Search results:
$search_results$

Question: answer naturally, as if chatting with a recruiter, in 2 to 4 sentences.
"""


def lambda_handler(event, context):
    if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
        return {"statusCode": 200, "headers": CORS_HEADERS, "body": ""}

    try:
        body = json.loads(event.get("body") or "{}")
        user_message = (body.get("message") or "").strip()

        if not user_message:
            return _response(400, {"error": "Missing 'message' in request body."})

        if len(user_message) > 500:
            return _response(400, {"error": "Message too long (max 500 characters)."})

        response = bedrock_agent_runtime.retrieve_and_generate(
            input={"text": user_message},
            retrieveAndGenerateConfiguration={
                "type": "KNOWLEDGE_BASE",
                "knowledgeBaseConfiguration": {
                    "knowledgeBaseId": KNOWLEDGE_BASE_ID,
                    "modelArn": MODEL_ARN,
                    "retrievalConfiguration": {
                        "vectorSearchConfiguration": {"numberOfResults": 5}
                    },
                    "generationConfiguration": {
                        "guardrailConfiguration": {
                            "guardrailId": GUARDRAIL_ID,
                            "guardrailVersion": GUARDRAIL_VERSION,
                        },
                        "inferenceConfig": {
                            "textInferenceConfig": {
                                "temperature": 0.3,
                                "maxTokens": 220,
                                "topP": 0.9,
                            }
                        },
                        "promptTemplate": {
                            "textPromptTemplate": PROMPT_TEMPLATE
                        },
                    },
                },
            },
        )

        answer = response["output"]["text"]
        return _response(200, {"answer": answer})

    except bedrock_agent_runtime.exceptions.ClientError as exc:
        print(f"Bedrock error: {exc}")
        return _response(502, {"error": "The AI assistant is temporarily unavailable."})

    except Exception as exc:  # noqa: BLE001
        print(f"Unexpected error: {exc}")
        return _response(500, {"error": "Something went wrong. Please try again."})


def _response(status_code, payload):
    return {
        "statusCode": status_code,
        "headers": {**CORS_HEADERS, "Content-Type": "application/json"},
        "body": json.dumps(payload),
    }