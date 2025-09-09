module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.13.0"
    
    name = local.name
    cidr = local.vpc_cidr

    azs = ["eu-west-3a", "eu-west-3b"]
    # or az
    # azs = data.aws_availability_zones.available.names
    private_subnets = local.private_subnets
    public_subnets  = local.public_subnets
    intra_subnets   = local.intra_subnets

    enable_nat_gateway = true
    

    # The following subnet tags are required for Kubernetes (EKS) to automatically discover and use the subnets for load balancers:
    # - "kubernetes.io/role/elb" on public subnets allows EKS to provision external (internet-facing) load balancers in these subnets.
    # - "kubernetes.io/role/internal-elb" on private subnets allows EKS to provision internal (private) load balancers in these subnets.
    # These tags are used by the AWS cloud controller manager to identify which subnets to use for different types of services.
    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }
  
}
data "aws_availability_zones" "available" {
  
}