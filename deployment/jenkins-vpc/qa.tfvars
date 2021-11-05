default_region = "us-east-1"

cidr_block         = "10.0.0.0/20"      # 4096 IPs, 10.0.0.0 - 10.0.15.255
instance_tenancy   = "default"
enable_dns         = "true"
support_dns        = "true"
enable_nat_gateway = "true"

private_azs_with_cidr = ["10.0.0.0/24","10.0.2.0/24","10.0.4.0/24"]
public_azs_with_cidr = ["10.0.1.0/24","10.0.3.0/24","10.0.5.0/24"]
db_azs_with_cidr = ["10.0.6.0/24","10.0.7.0/24","10.0.8.0/24"]


team                  = "LearningTeam"
owner                 = "Vivek"
isMonitoring          = true
project               = "Jenkins-Cluster-TF"