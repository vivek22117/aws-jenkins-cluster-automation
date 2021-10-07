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

output "route53_public_dns_name" {
  value = module.jenkins_master_cluster.route53_public_dns_name
}
