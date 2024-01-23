#Creating targt group
resource "aws_lb_target_group" "catalogue" {
  name     = "${local.name}-${var.tags.component}"
  port     = 8080  #catalogue port
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
      healthy_threshold   = 2  #two time sucessful it is healthy
      interval            = 10 #check every 10sec
      unhealthy_threshold = 3  #if no response after 3 failures declare unhealthy
      timeout             = 5  #requst time out after 5sec
      path                = "/health"
      port                = 8080
      matcher = "200-299"
  }
}

#Creating an ec2 instance
module "catalogue" {
  source                 = "terraform-aws-modules/ec2-instance/aws"  #open source module from internet
  ami                    = data.aws_ami.centos8.id
  name                   = "${local.name}-${var.tags.component}-ami"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]
  subnet_id              = element(split(",",data.aws_ssm_parameter.private_subnet_ids.value), 0)
  iam_instance_profile   = "Ansible_role_ec2_admin_access" #Iam role for ansible server to access parameterstore and botocore and boto3 also required to ansible to retrive the password. In bootstrap file we already installed it. Passwords will create manually in parameters store in real time.
  tags = merge(
    var.common_tags,
    var.tags
    ) 
}

#Installing the catalogue through anisble scripts
resource "null_resource" "catalogue" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = { #Triggers if any changes made on the mongodb instance
    instance_id = module.catalogue.id
  }

#Firs we need t connect to the server through SSH to run anything inside it
  connection {
    host = module.catalogue.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }

    provisioner "file" {
    source      = "bootstrap.sh"  
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue dev" 
    ]
  }
}

#Once it is done we can check with <catalogue_private_ip>http:8080/health, /categories
#we will get this output {"app":"OK","mongo":true}

#Stopping the server 
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = module.catalogue.id
  state       = "stopped"
  depends_on = [ null_resource.catalogue ] #Afte the null resource is created then only it will stop
}


#To create an AMI from catalogue instance
resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.name}-${var.tags.component}-${local.current_time}"
  source_instance_id = module.catalogue.id
}


#To delete the catalogue instance after ami creation
resource "null_resource" "catalogue_delete" {
  triggers = {
    instance_id = aws_ami_from_instance.catalogue.id
  }

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.catalogue.id}"
  }

  depends_on = [ aws_ami_from_instance.catalogue, null_resource.catalogue, aws_ec2_instance_state.catalogue ] #depends on ami creation
}

#Launch template 
resource "aws_launch_template" "catalogue" {
  name = "${local.name}-${var.tags.component}"

  image_id = aws_ami_from_instance.catalogue.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name}-${var.tags.component}"
    }
  }

}