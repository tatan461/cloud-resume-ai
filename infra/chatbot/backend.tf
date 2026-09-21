terraform {
  backend "s3" {
    bucket       = "cloud-resume-ai-tfstate-378356708535"
    key          = "chatbot/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}