variable "aws_vpc_id" {}
variable "env_prefix" {
    default = "devSecOps"
}
variable "my_ip" {
    default = "41.141.124.190/32"
}

variable "ami_id" {
    default = "ami-0e86e20dae9224db8"

}
variable "ssh_location" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "az" {}
variable "entry_script" {}
variable "server_name" {
    default = "JENKINS-SERVER"
}
variable "volume_size" {}
