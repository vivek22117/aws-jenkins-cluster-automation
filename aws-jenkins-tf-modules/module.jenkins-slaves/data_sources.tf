data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.environment}-jenkins-tfstate-${data.aws_caller_identity.current.account_id}-${var.default_region}"
    key    = "state/${var.environment}/jenkins-vpc/terraform.tfstate"
    region = var.default_region
  }
}


#####================Jenkins Master state file==================#####
data "terraform_remote_state" "jenkins_master" {
  backend = "s3"

  config = {
    bucket = "${var.environment}-jenkins-tfstate-${data.aws_caller_identity.current.account_id}-${var.default_region}"
    key    = "state/${var.environment}/jenkins-cluster/terraform.tfstate"
    region = var.default_region
  }
}

data "aws_caller_identity" "current" {}

