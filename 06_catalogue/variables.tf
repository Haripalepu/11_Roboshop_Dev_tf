
data "aws_ami" "centos8"{
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

variable "common_tags" {
    default = {
        Project = "roboshop"
        Environment = "dev"
        Terraform = "true"
    }  
}

variable "tags" {
  default = {
    component = "catalogue"
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

