locals {
    vpc_cidr_block = "10.0.0.0/16"
    region = "eu-west-3"
    name   = "budget-project-cluster"
    vpc_cidr = "10.0.0.0/16"
    azs      = ["eu-west-3a", "eu-west-3b"]
    public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
    intra_subnets   = ["10.0.5.0/24", "10.0.6.0/24"]
    tags = {
        Example = local.name
    }
}

provider "aws" {
    region = "eu-west-3"  
}
