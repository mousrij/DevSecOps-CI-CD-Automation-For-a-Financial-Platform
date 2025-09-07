provider "aws" {
    region = "eu-west-3"
  
}

resource "aws_vpc" "devSecOps-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "subnet" {
  source = "../modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  aws_vpc_id = aws_vpc.devSecOps-vpc.id
  availability_zone = var.avail_zone
  
}

module "server" {
    source = "../modules/server"
    subnet_id = module.subnet.subnet_id
    server_name = var.server_name
    az = var.avail_zone
    volume_size = var.volume_size
    ssh_location = var.ssh-location
    aws_vpc_id = aws_vpc.devSecOps-vpc.id
    ami_id = var.ami_id
    instance_type = var.instance_type
    entry_script = var.entry_script
    my_ip = var.my_ip

}