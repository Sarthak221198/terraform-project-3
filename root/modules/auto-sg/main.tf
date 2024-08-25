# Launch Template
# - Defines the launch configuration for EC2 instances in the Auto Scaling Group.
# - Uses an AMI, instance type, and key pair specified in variables.
# - Includes a user data script for configuration.
# - Associates a security group with the instances.
resource "aws_launch_template" "tf-lt" {
    name = "${var.project_name}-tp1"
    image_id = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    user_data = filebase64("./modules/auto-sg/config.sh")
    vpc_security_group_ids = [var.client_sg_id]
    tags = {
        Name = "${var.project_name}-tpl"
    }
}
# Auto Scaling Group
# - Manages a group of EC2 instances with automatic scaling based on defined policies.
# - Specifies minimum, maximum, and desired capacity for the group.
# - Uses a launch template for instance configuration.
# - Associates with a target group for load balancing.
# - Monitors various metrics to manage scaling.
resource "aws_autoscaling_group" "asg_name" {

  name                      = "${var.project_name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_cap
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type #"ELB" or default EC2
  vpc_zone_identifier = [var.pri_sub_3_a_id,var.pri_sub_4_b_id]
  target_group_arns   = [var.tg_arn] #var.target_group_arns

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.tf-lt.id
    version = aws_launch_template.tf-lt.latest_version 
  }
}

# Scale Up Policy
# - Defines a policy to increase the number of instances by 1 when triggered.
# - Uses the Auto Scaling Group and includes a cooldown period.
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg_name.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
  
}

# Scale Up Alarm
# - Triggers the scale-up policy based on CPU utilization exceeding 70%.
# - Configured to evaluate the average CPU utilization every 2 minutes.
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70" # New instance will be created once CPU utilization is higher than 70 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg_name.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
}

# Scale Down Policy
# - Defines a policy to decrease the number of instances by 1 when triggered.
# - Uses the Auto Scaling Group and includes a cooldown period.

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg_name.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# Scale Down Alarm
# - Triggers the scale-down policy based on CPU utilization falling below 5%.
# - Configured to evaluate the average CPU utilization every 2 minutes.
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${var.project_name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg_name.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}