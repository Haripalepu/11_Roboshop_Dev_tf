
variable "common_tags" {
    default = {
        Project = "roboshop"
        Environment = "dev"
        Terraform = "true"
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

# variable "zone_name" {
#   type = string
#   default = "Z0259905UVRRPZ13D1QO" #Replace with your zone id
# }