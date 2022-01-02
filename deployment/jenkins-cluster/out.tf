output "jenkins_role" {
  value = module.jenkins_master_cluster.jenkins_role
}

output "jenkins_elb_dns" {
  value = module.jenkins_master_cluster.jenkins_elb_dns
}

output "jenkins_master_sg" {
  value = module.jenkins_master_cluster.jenkins_master_sg
}

output "jenkins_key" {
  value = module.jenkins_master_cluster.jenkins_key
}

output "jenkins_profile" {
  value = module.jenkins_master_cluster.jenkins_profile
}

#####=========================================================================================#####
output "spot_price_current_max" {
  description = "Maximum current Spot Price, which allows to run all Instance Types in all AZ. Maximum stability."
  value       = module.jenkins_master_cluster.spot_price_current_max
}

output "spot_price_current_max_mod" {
  description = "Modified maximum current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply."
  value       = module.jenkins_master_cluster.spot_price_current_max_mod
}

output "spot_price_current_min" {
  description = "Minimum current Spot Price, which allows to run at least one Instance Type in at least one AZ. Lowest price."
  value       = module.jenkins_master_cluster.spot_price_current_min
}

output "spot_price_current_min_mod" {
  description = "Modified minimum current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply."
  value       = module.jenkins_master_cluster.spot_price_current_min_mod
}

output "spot_price_current_optimal" {
  description = "Optimal current Spot Price, which allows to run at least one Instance Type in all AZ. Balance between stability and costs."
  value       = module.jenkins_master_cluster.spot_price_current_optimal
}

output "spot_price_current_optimal_mod" {
  description = "Modified optimal current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply."
  value       = module.jenkins_master_cluster.spot_price_current_optimal_mod
}