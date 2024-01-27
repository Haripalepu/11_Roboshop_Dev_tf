#1.Create a target group
#2.Create and Web ec2 instance
#3.Provision it using shell/ansible
#4.Stop the server
#5.Create an AMI
#6.Delete the instance 
#7.Create launch template 
#8.Create auto scaling 

#Creating targt group
resource "aws_lb_target_group" "web" {
  name     = "${local.name}-${var.tags.component}"
  port     = 80  #web port
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  deregistration_delay = 60
  health_check {
      healthy_threshold   = 2  #two time sucessful it is healthy
      interval            = 10 #check every 10sec
      unhealthy_threshold = 3  #if no response after 3 failures declare unhealthy
      timeout             = 5  #requst time out after 5sec
      path                = "/health"
      port                = 80
      matcher = "200-299"
  }
}

#Creating an ec2 instance
module "web" {
  source                 = "terraform-aws-modules/ec2-instance/aws"  #open source module from internet
  ami                    = data.aws_ami.centos8.id
  name                   = "${local.name}-${var.tags.component}-ami"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.web_sg_id.value]
  subnet_id              = element(split(",",data.aws_ssm_parameter.private_subnet_ids.value), 0)
  iam_instance_profile   = "Ansible_role_ec2_admin_access" #Iam role for ansible server to access parameterstore and botocore and boto3 also required to ansible to retrive the password. In bootstrap file we already installed it. Passwords will create manually in parameters store in real time.
  tags = merge(
    var.common_tags,
    var.tags
    ) 
}

#Installing the web through anisble scripts
resource "null_resource" "web" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = { #Triggers if any changes made on the mongodb instance
    instance_id = module.web.id
  }

#First we need to connect to the server through SSH to run anything inside it
  connection {
    host = module.web.private_ip
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
      "sudo sh /tmp/bootstrap.sh web dev" 
    ]
  }
}

#Once it is done we can check in browser with <catalogue_private_ip>http:80/health, /categories
#we will get this output {"app":"OK","mongo":true}

#Stopping the server 
resource "aws_ec2_instance_state" "web" {
  instance_id = module.web.id
  state       = "stopped"
  depends_on = [ null_resource.web ] #After the null resource is created then only it will stop
}


#To create an AMI from web instance
resource "aws_ami_from_instance" "web" {
  name               = "${local.name}-${var.tags.component}-${local.current_time}"
  source_instance_id = module.web.id
  depends_on = [ aws_ec2_instance_state.web ]
}


# #To delete the web instance after ami creation
# resource "null_resource" "catalogue_delete" {
#   triggers = {
#     instance_id = module.web.id
#   }

#   provisioner "local-exec" {
#     command = "aws ec2 terminate-instances --instance-ids ${module.web.id}"
#   }

#   depends_on = [ aws_ami_from_instance.web ] #depends on ami creation
# }

#Launch template 
resource "aws_launch_template" "web" {
  name = "${local.name}-${var.tags.component}"

  image_id = aws_ami_from_instance.web.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  update_default_version = true #Template version will change when ever we update so we can use this to get latest versio
  vpc_security_group_ids = [data.aws_ssm_parameter.web_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name}-${var.tags.component}"
    }
  }

}

#AutoScaling
resource "aws_autoscaling_group" "web_autoscaling" {
  name                      = "${local.name}-${var.tags.component}"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  target_group_arns = [ aws_lb_target_group.web.arn ]

    launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  instance_refresh { #To replace all the old instances with latest version
    strategy = "Rolling" #It is a strategy to delete oldest instances first 
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-${var.tags.component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_lb_listener_rule" "web" {
  listener_arn = data.aws_ssm_parameter.web_alb_listener_arn.value
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }


  condition {
    host_header {
      values = ["${var.tags.component}-${var.environment}.${var.dns_name}"]
    }
  }
}

#scaling policy
resource "aws_autoscaling_policy" "web" {
  autoscaling_group_name = aws_autoscaling_group.web_autoscaling.name
  name                   = "${local.name}-${var.tags.component}"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
}


