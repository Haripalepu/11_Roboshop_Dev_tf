

variable "common_tags" {
    default = {
        Project = "roboshop"
        Environment = "dev"
        Terraform = "true"
    }  
}

variable "tags" {
  default = {
    component = "alb"
  }
}
variable "project_name" {
    default = "roboshop" 
}

variable "environment" {
    default = "dev" 
}

variable "dns_name" {
    type = string
    default = "haripalepu.cloud"
  
}

