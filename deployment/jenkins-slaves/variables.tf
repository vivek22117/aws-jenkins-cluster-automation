#####===========Global Variables==================#####
variable "environment" {
  type        = string
  description = "Environment to be configured 'dev', 'qa', 'prod'"
}

variable "component_name" {
  type = string
  description = "Component name for resources tag"
}

variable "volume_size" {
  type        = number
  description = "EBS volume size"
}

variable "volume_type" {
  type = string
  description = "EBS volume type"
}

variable "app_asg_max_size" {
  type        = string
  description = "ASG max size"
}

variable "app_asg_min_size" {
  type        = string
  description = "ASG min size"
}

variable "app_asg_desired_capacity" {
  type        = string
  description = "ASG desired capacity"
}

variable "app_asg_health_check_grace_period" {
  type        = string
  description = "ASG health check grace period"
}

variable "health_check_type" {
  type        = string
  description = "ASG health check type"
}

variable "app_asg_wait_for_elb_capacity" {
  type        = string
  description = "ASG waih for ELB capacity"
}

variable "default_cooldown" {
  type        = number
  description = "Cool-down value of ASG"
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated"
  type        = list(string)
}

variable "suspended_processes" {
  description = "The allowed values are Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZ-Rebalanced, AlarmNotification, ScheduledActions, AddToLoadBalancer"
  type        = list(string)
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  type        = string
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

##### =============================== Spot Price Script Config =============================#####
variable "instance_types_list" {
  description = "List of instance types. If not default will overwrite `instance_types_weighted_map`. "
  type        = list(string)
  default     = []
}

variable "instance_types_weighted_map" {
  description = "Map of instance_type and their weighted_capacity. Conflict with `instance_types_list`"
  type = list(object({
    instance_type     = string
    weighted_capacity = string
  }))
  default = [{ instance_type = "t3a.small", weighted_capacity = "1" }]
}

variable "instance_weight_default" {
  type        = number
  description = "Default number of capacity units for all instance types."
  default     = 1

  validation {
    condition     = var.instance_weight_default >= 1 && var.instance_weight_default <= 999
    error_message = "Value must be in the range of 1 to 999."
  }
}

variable "product_description_list" {
  type        = list(string)
  description = "The product description for the Spot price (Linux/UNIX | Red Hat Enterprise Linux | SUSE Linux | Windows | Linux/UNIX (Amazon VPC) | Red Hat Enterprise Linux (Amazon VPC) | SUSE Linux (Amazon VPC) | Windows (Amazon VPC))."
  default     = ["Linux/UNIX", "Linux/UNIX (Amazon VPC)"]
}

variable "custom_price_modifier" {
  type        = number
  description = "Modifier for getting custom prices. Must be between 1 and 2. Values greater than 1.7 will often not make sense. Because it will be equal or greater than on-demand price."
  default     = 1.05
  validation {
    condition     = var.custom_price_modifier >= 1 && var.custom_price_modifier <= 2
    error_message = "Modifier for getting custom prices. Must be between 1 and 2. Values greater than 1.7 will often not make sense. Because it will be equal or greater than on-demand price."
  }
}

variable "normalization_modifier" {
  type        = number
  description = "Modifier for price normalization (rounded up / ceil). Helps to avoid small price fluctuations. Must be 10, 100, 1000 or 10000."
  default     = 1000
  validation {
    condition     = contains([10, 100, 1000, 10000], var.normalization_modifier)
    error_message = "Modifier for price normalization must be 10, 100, 1000 or 10000."
  }
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

