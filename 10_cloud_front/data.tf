
data "aws_ssm_parameter" "web_alb_dns_name" {   #from 08_web_alb/parameters.tf
  name  = "/${var.project_name}/${var.environment}/web_alb_dns_name"
}

data "aws_ssm_parameter" "acm_certificate_arn" {  #From 07_certificate_manager/parameters.tf 
  name  = "/${var.project_name}/${var.environment}/acm_certificate_arn"
}

