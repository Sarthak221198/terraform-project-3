# Define the Application Load Balancer (ALB) resource
# - `name`: Sets the name of the ALB using the project name variable.
# - `internal`: Set to false to make the ALB accessible from the internet (public).
# - `load_balancer_type`: Specifies the load balancer type as "application".
# - `security_groups`: Assigns the ALB to a specified security group for access control.
# - `subnets`: Lists the public subnets where the ALB will be deployed.
# - `enable_deletion_protection`: Disabled to allow the ALB to be deleted if needed.
# - `tags`: Tags for the ALB to help with identification and management.
resource "aws_lb" "application_load_balancer" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.pub_sub_1_a_id,var.pub_sub_2_b_id]
  enable_deletion_protection = false

  tags   = {
    Name = "${var.project_name}-alb"
  }
}

# Define the Target Group for the ALB
# - `name`: Sets the name of the target group using the project name variable.
# - `target_type`: Specifies the type of target as EC2 instances.
# - `port`: The port on which the targets (EC2 instances) will receive traffic.
# - `protocol`: The protocol used for communication with the targets.
# - `vpc_id`: Specifies the VPC where the target group will be associated.
# - `health_check`: Configuration for health checks to monitor the health of targets.
# - `lifecycle`: Ensures that the target group is created before being destroyed to prevent downtime.
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.project_name}-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Define the ALB listener for HTTP traffic on port 80
# - `load_balancer_arn`: Specifies the ARN of the ALB to which this listener will be attached.
# - `port`: The port on which the listener will accept incoming traffic (port 80 for HTTP).
# - `protocol`: The protocol used by the listener (HTTP in this case).
# - `certificate_arn`: Optional field for HTTPS; not used here as HTTP is specified.
# - `default_action`: Defines the default action for the listener, which is to forward traffic to the target group.

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  certificate_arn    =  var.aws_acm_certificate_validation_acm_certificate_validation_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}