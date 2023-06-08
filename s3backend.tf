terraform {
  backend "s3" {
    bucket = "wk21bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}