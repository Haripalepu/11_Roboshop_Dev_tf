
resource "aws_lb" "alb" {
  name               = "${local.name}-${var.tags.component}" #local.name=roboshop-dev and var.tags.common=alb
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.alb_sg_id.value] #from data.tf
  subnets            = split(",", data.aws_ssm_parameter.private_subnet_ids.value) #In aws paramertsstore the value are seperated by , so we have to split it

  #enable_deletion_protection = true

  tags = merge(
    var.common_tags,
    var.tags
    )
}


#ALB listner

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {  #Testisng purpose
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hi, This response is from APP ALB"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.dns_name

  records = [
    {
      name    = "*.alb-${var.environment}"
      type    = "A"
      alias   = {
        name    = aws_lb.alb.dns_name
        zone_id = aws_lb.alb.zone_id
      }
    }
  ]
}