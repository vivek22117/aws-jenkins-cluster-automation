#####===========Global Variables==================#####
variable "profile" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type        = string
  description = "Environment to be configured 'dev', 'qa', 'prod'"
}

variable "component_name" {
  type = string
  description = "Component name for resources tag"
}

variable "instance_types_list" {
  description = "List of instance types. If not default will overwrite `instance_types_weighted_map`. "
  type        = list(string)
  default     = []
}


variable "jenkins_username" {
  description = "Jenkins username"
}

variable "jenkins_password" {
  description = "Jenkins password"
}

variable "jenkins_credentials_id" {
  description = "Slaves SSH ID"
}

variable "spot_price" {
  type        = string
  description = "EC2 spot price"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type to launch!"
}

variable "instance_count" {
  type        = number
  description = "Number of jenkins slaves to launch"
}

variable "max_count" {
  type        = number
  description = "Max count for autoscaling group"
}

//Default Variables
variable "default_region" {
  type    = string
  default = "us-east-1"
}

#####=============ASG Standards Tags===============#####
variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default = {
    owner      = "Vivek"
    team       = "Learning-Group"
    tool       = "Terraform"
    monitoring = "true"
    Name       = "Jenkins-Salve"
  }
}

#####================Local variables===============#####
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "Learning-Group"
    environment = var.environment
  }
}

