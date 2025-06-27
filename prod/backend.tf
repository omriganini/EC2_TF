terraform {
  backend "s3" {
    bucket         = "my-terraform-prod-state"
    key            = "envs/prod/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}