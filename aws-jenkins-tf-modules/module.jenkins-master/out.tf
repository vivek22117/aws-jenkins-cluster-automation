output "jenkins_role" {
  value = aws_iam_role.jenkins_access_role.arn
}

output "jenkins_elb_dns" {
  value = aws_alb.jenkins_alb.dns_name
}

output "jenkins_master_sg" {
  value = aws_security_group.jenkins_master_sg.id
}

output "jenkins_key" {
  value = aws_key_pair.ssh_key.key_name
}

output "jenkins_profile" {
  value = aws_iam_instance_profile.jenkins_profile.arn
}

output "route53_public_dns_name" {
  value = aws_route53_record.jenkins_record.*.name[0]
}

#####=========================================================#####
output "spot_price_current_max" {
  description = "Maximum current Spot Price, which allows to run all Instance Types in all AZ. Maximum stability."
  value       = local.spot_price_current_max
}

output "spot_price_current_max_mod" {
  description = "Modified maximum current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply."
  value       = local.spot_price_current_max_mod
}

output "spot_price_current_min" {
  description = "Minimum current Spot Price, which allows to run at least one Instance Type in at least one AZ. Lowest price."
  value       = local.spot_price_current_min
}

output "spot_price_current_min_mod" {
  description = "Modified minimum current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply."
  value       = local.spot_price_current_min_mod
}

output "spot_price_current_optimal" {
  description = "Optimal current Spot Price, which allows to run at least one Instance Type in all AZ. Balance between stability and costs."
  value       = local.spot_price_current_optimal
}

output "spot_price_current_optimal_mod" {
  description = "Modified optimal current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply."
  value       = local.spot_price_current_optimal_mod
}