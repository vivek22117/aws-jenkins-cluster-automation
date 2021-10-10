####################################################
#        Jenkins Master module implementation      #
####################################################
module "jenkins_master_cluster" {
  source = "../../aws-jenkins-tf-modules/module.jenkins-master"

  environment    = var.environment
  component_name = var.component_name

  volume_type = var.volume_type

  app_asg_desired_capacity          = var.app_asg_desired_capacity
  app_asg_health_check_grace_period = var.app_asg_health_check_grace_period
  app_asg_max_size                  = var.app_asg_max_size
  app_asg_min_size                  = var.app_asg_min_size
  app_asg_wait_for_elb_capacity     = var.app_asg_wait_for_elb_capacity
  default_cooldown                  = var.default_cooldown
  wait_for_capacity_timeout         = var.wait_for_capacity_timeout
  suspended_processes               = var.suspended_processes
  termination_policies              = var.termination_policies

  default_target_group_port = var.default_target_group_port
  health_check_type         = var.health_check_type
  volume_size               = var.volume_size
  jenkins_dns_name          = var.jenkins_dns_name
}
