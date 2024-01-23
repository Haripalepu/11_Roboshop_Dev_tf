
data "aws_ami" "centos8"{    #When ever the ami_id changes we will get the latest id.
    owners = ["973714476881"]
    most_recent      = true

    filter {
        name   = "name"
        values = ["Centos-8-DevOps-Practice"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

#The security group id is stored in paramterstore and now we are fetching it using data store
data "aws_ssm_parameter" "mongodb_sg_id" { #resource name in parameter.tf file 11th line.
    name = "/${var.project_name}/${var.environment}/mongodb_sg_id"
}

data "aws_ssm_parameter" "redis_sg_id" { #resource name in parameter.tf file 
    name = "/${var.project_name}/${var.environment}/redis_sg_id"
}

data "aws_ssm_parameter" "mysql_sg_id" { #resource name in parameter.tf file 
    name = "/${var.project_name}/${var.environment}/mysql_sg_id"
}

data "aws_ssm_parameter" "rabbitmq_sg_id" { #resource name in parameter.tf file 
    name = "/${var.project_name}/${var.environment}/rabbitmq_sg_id"
}



#The subnet id is stored in paramterstore(09_terrafrom_modules) we are fetching using data sources.
data "aws_ssm_parameter" "database_subnet_ids" { 
    name = "/${var.project_name}/${var.environment}/database_subnet_ids"
}



data "aws_ssm_parameter" "vpn_sg_id" { 
    name = "/${var.project_name}/${var.environment}/vpn_sg_id"
}

#Default vpc for ansible 
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "selected" {
  vpc_id = data.aws_vpc.default.id
  availability_zone = "us-east-1a"
}