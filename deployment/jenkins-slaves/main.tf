####################################################
#        Jenkins Slaves module implementation      #
####################################################
module "jenkins_efs_cluster" {
  source = "../../aws-jenkins-tf-modules/module.jenkins-slaves"

  environment = var.environment

  instance_count = 0
  instance_type = ""
  jenkins_credentials_id = ""
  jenkins_password = ""
  jenkins_username = ""
  max_count = 0
  profile = ""
  spot_price = ""
}
