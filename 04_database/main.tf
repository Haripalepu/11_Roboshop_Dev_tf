
#Creating mongodb instance 
module "mongodb" {
  source                 = "terraform-aws-modules/ec2-instance/aws"  #open source module from internet
  ami                    = data.aws_ami.centos8.id
  name                   = "${local.ec2_name}-mongodb"
  instance_type          = "t3.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.mongodb_sg_id.value]
  subnet_id              = local.database_subnet_id

  tags = merge(
    var.common_tags,
    {
        component        = "mongodb"
    },
    {
        Name             = "${local.ec2_name}-mongodb"
    }
  )
}

#userdata/bootstrap wil not show the output unless we check the logs so we are using provisioners so we can see the output in the terminal
#we can connect provisioners using null resource 

resource "null_resource" "mongodb" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = { #Triggers if any changes made on the mongodb instance
    instance_id = module.mongodb.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case

  connection {
    host = module.mongodb.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }

    provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mongodb dev" 
    ]
  }
}


#Creating redis instance 
module "redis" {
  source                 = "terraform-aws-modules/ec2-instance/aws"  #open source module from internet
  ami                    = data.aws_ami.centos8.id
  name                   = "${local.ec2_name}-redis"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.redis_sg_id.value]
  subnet_id              = local.database_subnet_id

  tags = merge(
    var.common_tags,
    {
        component        = "redis"
    },
    {
        Name             = "${local.ec2_name}-redis"
    }
  )
}



resource "null_resource" "redis" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = { #Triggers if any changes made on the mongodb instance
    instance_id = module.redis.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case

  connection {
    host = module.redis.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }

    provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh redis dev" 
    ]
  }
}


#Creating mysql instance

module "mysql" {
  source                 = "terraform-aws-modules/ec2-instance/aws"  #open source module from internet
  ami                    = data.aws_ami.centos8.id
  name                   = "${local.ec2_name}-mysql"
  instance_type          = "t3.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.mysql_sg_id.value]
  subnet_id              = local.database_subnet_id
  iam_instance_profile   = "Ansible_role_ec2_admin_access" #Iam role for ansible server to access parameterstore and botocore and boto3 also required to ansible to retrive the password. In bootstrap file we already installed it. Passwords will create manually in parameters store in real time.
  tags = merge(
    var.common_tags,
    {
        component        = "mysql"
    },
    {
        Name             = "${local.ec2_name}-mysql"
    }
  )
}



resource "null_resource" "mysql" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = { #Triggers if any changes made on the mongodb instance
    instance_id = module.mysql.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case

  connection {
    host = module.mysql.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }

    provisioner "file" {
    source      = "bootstrap.sh"  
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mysql dev" 
    ]
  }
}




#Creating rabbitmq instance 
module "rabbitmq" {
  source                 = "terraform-aws-modules/ec2-instance/aws"  #open source module from internet
  ami                    = data.aws_ami.centos8.id
  name                   = "${local.ec2_name}-rabbitmq"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.rabbitmq_sg_id.value]
  subnet_id              = local.database_subnet_id

  tags = merge(
    var.common_tags,
    {
        component        = "rabbitmq"
    },
    {
        Name             = "${local.ec2_name}-rabbitmq"
    }
  )
}



resource "null_resource" "rabbitmq" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = { #Triggers if any changes made on the mongodb instance
    instance_id = module.rabbitmq.id
  }

 

  connection {
    host = module.rabbitmq.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }

    provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh rabbitmq dev" 
    ]
  }
}