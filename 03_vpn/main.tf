

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"  #open source module from internet
  ami = data.aws_ami.centos8.id
  name = "${local.ec2_name}-vpn"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  subnet_id              = data.aws_subnet.selected.id
  user_data = file("openvpn.sh")
  tags = merge(
    var.common_tags,
    {
        component = "vpn"
    },
    {
        Name = "${local.ec2_name}-vpn"
    }
  )
}


#Login to the vpn server and cat the keypair in root and configure in vpn client

#To check the userdata script logos 
# cd /var/log/
# tail -f cloud-init-output.log or less cloud-init-output.log

 