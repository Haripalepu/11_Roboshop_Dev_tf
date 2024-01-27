
#When ever we create a new module we have to do terrafrom init
module "vpn" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_vpc.default.id
    sg_name = "vpn"
    sg_description = "SecurityGroup for vpn"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}
module "mongodb" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "mongodb"
    sg_description = "SecurityGroup for mongodb"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "redis" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "redis"
    sg_description = "SecurityGroup for redis"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "mysql" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "mysql"
    sg_description = "SecurityGroup for mysql"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "rabbitmq" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "rabbitmq"
    sg_description = "SecurityGroup for rabbitmq"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "cart" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "cart"
    sg_description = "SecurityGroup for cart"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "shipping" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "shipping"
    sg_description = "SecurityGroup for shipping"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "payment" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "payment"
    sg_description = "SecurityGroup for payment"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "web" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "web"
    sg_description = "SecurityGroup for web"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "catalogue" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "catalogue"
    sg_description = "SecurityGroup for catalogue"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "user" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "user"
    sg_description = "SecurityGroup for user"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}


#App Alb security group(Private load balancer)
module "alb" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "alb"
    sg_description = "SecurityGroup for ALB"
    #sg_ingress_rules = var.mongodb_sg_ingress_rules
}

#web_alb security group(Public load balancer)
module "web_alb" {
    source = "../../09_Terraform_Modules/02_sg_module"
    project_name = var.project_name
    environment = var.environment
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "web_alb"
    sg_description = "SecurityGroup for web ALB"
}

#Web ALB security group rule it should accept connects only form internet as it is public LB
resource "aws_security_group_rule" "web_alb" {
  cidr_blocks              = ["0.0.0.0/0"]
  type                     = "ingress"
  from_port                = 443 #If we are using 443 then certifacte required 
  to_port                  = 443
  protocol                 = "tcp" 
  security_group_id = module.web_alb.sg_id
}

#Alb security group rule it should accept connects only form vpn as it is internal/private LB
resource "aws_security_group_rule" "alb_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp" 
  security_group_id = module.alb.sg_id
}

#App ALB should accept connects from web server
resource "aws_security_group_rule" "alb_web" {
  source_security_group_id = module.web.sg_id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp" 
  security_group_id = module.alb.sg_id
}
#Openvpn security group rule
resource "aws_security_group_rule" "vpn_home" {
  security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  cidr_blocks        = ["0.0.0.0/0"] #Usually we give home public ip address but here the ip changes frequently
}

resource "aws_security_group_rule" "mongodb_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.mongodb.sg_id
}

#mongodb accepting connections from catalogue instance
#We are adding a rule in mongodb sg group to allow 27017 port to catalogue ip/sg group
resource "aws_security_group_rule" "mongodb_catalogue" {
  source_security_group_id = module.catalogue.sg_id
  type                     = "ingress"
  from_port                = 27017 #mongodb port 
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = module.mongodb.sg_id
}

#mongodb accepting connections from user instance
resource "aws_security_group_rule" "mongodb_user" {
  source_security_group_id = module.user.sg_id
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = module.mongodb.sg_id
}

resource "aws_security_group_rule" "redis_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.redis.sg_id
}

#redis is accepting connections from cart instance
#We are adding a rule in redis sg group to allow 6379 port to cart ip/sg group
resource "aws_security_group_rule" "redis_cart" {
  source_security_group_id = module.cart.sg_id
  type                     = "ingress"
  from_port                = 6379 #redis port 
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.redis.sg_id
}

#redis is accepting connections from user instance
resource "aws_security_group_rule" "redis_user" {
  source_security_group_id = module.user.sg_id
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = module.redis.sg_id
}

resource "aws_security_group_rule" "mysql_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.mysql.sg_id
}

resource "aws_security_group_rule" "mysql_shipping" {
  source_security_group_id = module.shipping.sg_id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.mysql.sg_id
}


resource "aws_security_group_rule" "rabbitmq_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.rabbitmq.sg_id
}

resource "aws_security_group_rule" "rabbitmq_payment" {
  source_security_group_id = module.payment.sg_id
  type                     = "ingress"
  from_port                = 5672
  to_port                  = 5672
  protocol                 = "tcp"
  security_group_id        = module.rabbitmq.sg_id
}

resource "aws_security_group_rule" "catalogue_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.catalogue.sg_id
}

#to test from outisde using alb we are giving port 8080
resource "aws_security_group_rule" "catalogue_vpn_http_alb" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_alb" {
  source_security_group_id = module.alb.sg_id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.catalogue.sg_id
}

# resource "aws_security_group_rule" "catalogue_cart" {
#   source_security_group_id = module.cart.sg_id
#   type                     = "ingress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = module.catalogue.sg_id
# }

resource "aws_security_group_rule" "user_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.user.sg_id
}

resource "aws_security_group_rule" "user_alb" {
  source_security_group_id = module.alb.sg_id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.user.sg_id
}

# resource "aws_security_group_rule" "user_web" {
#   source_security_group_id = module.web.sg_id
#   type                     = "ingress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = module.user.sg_id
# }

# resource "aws_security_group_rule" "user_payment" {
#   source_security_group_id = module.payment.sg_id
#   type                     = "ingress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = module.user.sg_id
# }

resource "aws_security_group_rule" "cart_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.cart.sg_id
}

resource "aws_security_group_rule" "cart_web" {
  source_security_group_id = module.web.sg_id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.cart.sg_id
}

resource "aws_security_group_rule" "cart_shipping" {
  source_security_group_id = module.shipping.sg_id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.cart.sg_id
}

resource "aws_security_group_rule" "cart_payment" {
  source_security_group_id = module.payment.sg_id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.cart.sg_id
}

resource "aws_security_group_rule" "shipping_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.shipping.sg_id
}

resource "aws_security_group_rule" "shipping_web" {
  source_security_group_id = module.web.sg_id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.shipping.sg_id
}

resource "aws_security_group_rule" "payment_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.payment.sg_id
}

resource "aws_security_group_rule" "payment_web" {
  source_security_group_id = module.web.sg_id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.payment.sg_id
}

resource "aws_security_group_rule" "web_vpn" {
  source_security_group_id = module.vpn.sg_id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.web.sg_id
}

resource "aws_security_group_rule" "web_internet" {
  cidr_blocks = ["0.0.0.0/0"]
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.web.sg_id
}