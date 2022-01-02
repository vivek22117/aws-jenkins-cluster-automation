#####==================Jenkins slaves resource template===================#####
data "template_file" "user_data_slave" {
  template = file("scripts/join-cluster.tpl")

  vars = {
    jenkins_url            = "http://${data.terraform_remote_state.jenkins_master.outputs.jenkins_elb_dns}"
    jenkins_username       = var.jenkins_username
    jenkins_password       = var.jenkins_password
    jenkins_credentials_id = var.jenkins_credentials_id
    environment            = var.environment
  }
}

#####=============jenkins slaves launch template=========================#####
resource "aws_launch_template" "jenkins_master_lt" {
  name_prefix = "${var.component_name}-lt-${var.environment}"

  update_default_version = true
  image_id               = data.aws_ami.jenkins-slave-ami.id
  instance_type          = local.instance_types[0]
  key_name               = data.terraform_remote_state.jenkins_master.outputs.jenkins_key

  user_data = base64encode(data.template_file.user_data_slave.rendered)

  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    arn = data.terraform_remote_state.jenkins_master.outputs.jenkins_profile
  }

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false
    security_groups             = [aws_security_group.jenkins_slaves_sg.id]
    delete_on_termination       = true
  }

  placement {
    tenancy = "default"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, map("Project", "${var.component_name}-node"))
  }

  lifecycle {
    create_before_destroy = true
  }
}


#####===========================ASG Jenkins slaves===============================#####
resource "aws_autoscaling_group" "jenkins_slaves_asg" {
  name_prefix = "${var.component_name}-asg-${var.environment}"

  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnets

  capacity_rebalance = true

  termination_policies      = var.termination_policies
  max_size                  = var.app_asg_max_size
  min_size                  = var.app_asg_min_size
  desired_capacity          = var.app_asg_desired_capacity
  health_check_grace_period = var.app_asg_health_check_grace_period
  health_check_type         = var.health_check_type
  wait_for_elb_capacity     = var.app_asg_wait_for_elb_capacity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  default_cooldown    = var.default_cooldown
  suspended_processes = var.suspended_processes

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.jenkins_master_lt.id
        version            = aws_launch_template.jenkins_master_lt.latest_version
      }
      dynamic "override" {
        for_each = local.instance_types
        content {
          instance_type     = override.value
          weighted_capacity = "1"
        }
      }
    }
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
      spot_max_price                           = local.spot_price_current_max
      #spot_max_price                           = local.spot_price_current_min_mod
      #spot_max_price                           = local.spot_price_current_optimal
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50 # demo only, 90
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = var.custom_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}


#####===============Jenkins Slave ASG scaling alarm and policy==================#####
resource "aws_cloudwatch_metric_alarm" "high_cpu_jenkins_slaves_alarm" {
  alarm_name          = "high-cpu-jenkins-slaves-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_slaves_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-jenkins-slaves"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_slaves_asg.name
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_jenkins_slaves_alarm" {
  alarm_name          = "low-cpu-jenkins-slaves-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_slaves_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_in.arn]
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-jenkins-slaves"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_slaves_asg.name
}

