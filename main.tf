provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

provider "aws" {
  profile = "default"
  alias   = "us-east-1"
  region  = "us-east-1"
}

