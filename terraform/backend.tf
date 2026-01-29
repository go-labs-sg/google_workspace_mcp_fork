terraform {
  backend "s3" {
    region = "ap-southeast-1"
    key    = "app/terraform.tfstate"
  }
}
