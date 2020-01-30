
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "secutrity-group"
  description = "Security group for example usage with EC2 instance"
  vpc_id      =  var.aws_vpc

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "ec2" {
  source = "../../"

  instance_count = var.instances_number

  name                        = var.instancename
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
}

resource "aws_volume_attachment" "this_ec2" {
  count = var.instances_number

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this[count.index].id
  instance_id = module.ec2.id[count.index]
}

resource "aws_ebs_volume" "this" {
  count = var.instances_number

  availability_zone = module.ec2.availability_zone[count.index]
  size              = var.ebs_size
}
