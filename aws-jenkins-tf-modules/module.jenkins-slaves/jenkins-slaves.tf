locals {
  azs_max  = 3
  instance_types = length(var.instance_types_list) == 0 ? ["t3a.small", "t2.small"] : var.instance_types_list
}

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

#####=============jenkins slaves launch configuration=========================#####
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
  name_prefix = "${aws_launch_configuration.jenkins_slave_launch_conf.name}-asg"

  max_size             = var.max_count
  min_size             = var.environment == "prod" ? 2 : var.instance_count
  desired_capacity     = var.environment == "prod" ? 2 : var.instance_count
  vpc_zone_identifier  = data.terraform_remote_state.vpc.outputs.private_subnets
  launch_configuration = aws_launch_configuration.jenkins_slave_launch_conf.name

  health_check_grace_period = 100
  health_check_type         = "EC2"

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


#####===============Jenkins Slave ASG scalaing alarm and policy==================#####
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

