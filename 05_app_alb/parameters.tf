
resource "aws_ssm_parameter" "alb_listener_arn" {
  name  = "/${var.project_name}/${var.environment}/alb_listener_arn"
  type  = "String"
  value = aws_lb_listener.http.arn
}