terraform {
  backend "s3" {}

  required_providers {
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "3.2.0"
    }

    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "4.21.0"
    }
  }
}

provider "random" {}
provider "aws" {}

resource "random_pet" "pool_name" {}

resource "aws_cognito_user_pool" "pool" {
  name = random_pet.pool_name.id
}

resource "random_pet" "domain_prefix" {}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = random_pet.domain_prefix.id
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "random_pet" "client_name" {}

resource "aws_cognito_user_pool_client" "client" {
  name = random_pet.client_name.id

  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret                      = true
  callback_urls                        = ["http://localhost:3000/api/auth/callback/cognito"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]
}

output "COGNITO_CLIENT_ID" {
  sensitive = true
  value     = aws_cognito_user_pool_client.client.id
}

output "COGNITO_CLIENT_SECRET" {
  sensitive = true
  value     = aws_cognito_user_pool_client.client.client_secret
}

output "COGNITO_ISSUER" {
  sensitive = true
  value     = "https://${aws_cognito_user_pool.pool.endpoint}"
}