
variable "vpc_cidr" {
    default = "10.0.0.0/16"
  }

variable "common_tags" {
  default = {
    Name = "roboshop"
    Environment = "dev"
    Terraform = "true"
  }
}

variable "vpc_tags" {
  default = {}
}

variable "project_name" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "public_subnet_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  
}

variable "private_subnet_cidr" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  
}

variable "database_subnet_cidr" {
  default = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "is_peering_required" {
  default = true
  
}

# variable "overwrite" {
#   type = bool
#   default = true

# }

