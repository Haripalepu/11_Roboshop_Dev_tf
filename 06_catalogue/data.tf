
data "aws_ssm_parameter" "alb_sg_id" { #from 02_sg parameters.tf 72line
  name  = "/${var.project_name}/${var.environment}/alb_sg_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "catalogue_sg_id" {
  name = "/${var.project_name}/${var.environment}/catalogue_sg_id"
}

data "aws_ssm_parameter" "alb_listener_arn" {
  name  = "/${var.project_name}/${var.environment}/alb_listener_arn"
}


