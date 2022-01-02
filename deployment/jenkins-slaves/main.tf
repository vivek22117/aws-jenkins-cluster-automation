####################################################
#        Jenkins Slaves module implementation      #
####################################################
module "jenkins_slave" {
  source = "../../aws-jenkins-tf-modules/module.jenkins-slaves"

  environment = var.environment

  instance_count = var.instance_count
  instance_type = var.instance_type
  jenkins_credentials_id = var.jenkins_credentials_id
  jenkins_password = var.jenkins_password
  jenkins_username = var.jenkins_username
  max_count = var.max_count
  spot_price = var.spot_price
  app_asg_desired_capacity = var.app_asg_desired_capacity
  app_asg_health_check_grace_period = var.app_asg_health_check_grace_period
  app_asg_max_size = var.app_asg_max_size
  app_asg_min_size = var.app_asg_min_size
  app_asg_wait_for_elb_capacity = var.app_asg_wait_for_elb_capacity
  component_name = var.component_name
  default_cooldown = var.default_cooldown
  health_check_type = var.health_check_type
  suspended_processes = var.suspended_processes
  termination_policies = var.termination_policies
  volume_size = var.volume_size
  volume_type = var.volume_type
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
}
