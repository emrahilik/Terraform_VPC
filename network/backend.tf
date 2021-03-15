/* terraform {
  required_version = "~> 0.13"
  backend "s3" {
    bucket               = "bucket_name"    # the bucket name must be unique.
    region               = "us-east-1"
    key                  = "backend.tfstate"
    workspace_key_prefix = "network"
    dynamodb_table       = "terraform-lock"
    profile              = "profile_name"
  }
} */
