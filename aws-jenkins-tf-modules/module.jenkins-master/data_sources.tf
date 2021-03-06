data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.environment}-jenkins-tfstate-${data.aws_caller_identity.current.account_id}-${var.default_region}"
    key    = "state/${var.environment}/jenkins-vpc/terraform.tfstate"
    region = var.default_region
  }
}

data "terraform_remote_state" "jenkins_efs" {
  backend = "s3"

  config = {
    bucket = "${var.environment}-jenkins-tfstate-${data.aws_caller_identity.current.account_id}-${var.default_region}"
    key    = "state/${var.environment}/jenkins-efs-cluster/terraform.tfstate"
    region = var.default_region
  }
}

data "template_file" "script" {
  template = file("${path.module}/script/user-data.tpl")

  vars = {
    efs_id = data.terraform_remote_state.jenkins_efs.outputs.efs_dns
  }
}

//TO DO...
/*data "template_file" "ecs_task_policy_template" {
  template = file("${path.module}/policy-scripts/jenkins-access-policy.json")

  vars = {
    account_id     = data.aws_caller_identity.current.id
    environment    = var.environment
    aws_region = var.default_region
  }
}*/

data "aws_caller_identity" "current" {}