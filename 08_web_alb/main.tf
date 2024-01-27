#1.Create public application load balancer. 
#2.Create a listener 443.  
#3.create a listener rule

#1.Create public application load balancer. 
resource "aws_lb" "web_alb" {
  name               = "${local.name}-${var.tags.component}" #local.name=roboshop-dev and var.tags.common=web_alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.web_alb_sg_id.value] #from data.tf
  subnets            = split(",", data.aws_ssm_parameter.public_subnet_ids.value) #In aws paramertsstore the value are seperated by , so we have to split it

  #enable_deletion_protection = true

  tags = merge(
    var.common_tags,
    var.tags
    )
}

#2.Create a listener 443.
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" #We can get this from listener securitypolicy
  certificate_arn   = data.aws_ssm_parameter.acm_certificate_arn.value

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is from WEB ALB using HTTPS"
      status_code  = "200"
    }
  }
}

#Create route53 records
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.dns_name

  records = [
    {
      name    = "web-${var.environment}"
      type    = "A"
      alias   = {
        name    = aws_lb.web_alb.dns_name
        zone_id = aws_lb.web_alb.zone_id
      }
    }
  ]
}
