####################################################
#        EFS Cluster module implementation         #
####################################################
module "jenkins_efs_cluster" {
  source = "../../aws-jenkins-tf-modules/module.jenkins-efs-cluster"

  environment = var.environment

  efs_lifecycle    = var.efs_lifecycle
  isEncrypted      = var.isEncrypted
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
}
