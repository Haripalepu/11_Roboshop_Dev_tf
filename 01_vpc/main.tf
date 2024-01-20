
module "aws_vpc" {
  source = "../../09_Terraform_Modules/01_vpc_module" # Or we can push the module to git and we can give the git https repo url
  #source = "git::https://github.com/hari-palepu/09_Terraform_Modules.git?ref=main"  #ref=main branch
  project_name = var.project_name
  environment = var.environment
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr
  is_peering_required = var.is_peering_required 
  
}