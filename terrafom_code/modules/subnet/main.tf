

/*
so our objective is to create an Ec2 instance : 
but first we need to provision what Ec2 depends on before it start initiating
    it must be within
    a Region : 
    - Internet gateway
    -  VPC:
        - route table 
        - subnet
            - EC2 instance
    
So our plan now is to do terraform resource block to provision what indicated before
- my plan is to create a module of these things 
    -> IGW
    -> RT                     <---- make resource of these
    -> Subnet
*/

# AWS Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


## Now it's time to provision the igw
resource "aws_internet_gateway" "devSecOps_igw" {
    vpc_id = var.aws_vpc_id

    tags = {
      Name = "${var.env_prefix}-igw"
    }
  
}

## Now it's time to provision the route Table specifically aws_route this time not aws_route_table 
# to ensure dynamic and frequent changes in routes and avoid potential Downtimes


##### that was a misunderstand on the way route works 
# aws route is if we want to add new route we choose aws_route to not re-create the table route from scratch


resource "aws_route_table" "devSecOps_rtb" {
    vpc_id = var.aws_vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devSecOps_igw.id
    }

    tags = {
        Name = "${var.env_prefix}-rtb"
    }
  
}


# now we comes to provision the subnet 

resource "aws_subnet" "devSecOps_subnet" {
    vpc_id = var.aws_vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    
    tags = {
      Name : "${var.env_prefix}-subnet-1"
    }
  
}

resource "aws_route_table_association" "my_rt_assoc" {
  subnet_id = aws_subnet.devSecOps_subnet.id
  route_table_id = aws_route_table.devSecOps_rtb.id
}