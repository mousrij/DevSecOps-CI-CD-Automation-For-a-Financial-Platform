variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {
    default = "devSecOps"
}
variable my_ip {}
variable server_name {}
variable volume_size {}

variable "ssh-location" {}
variable "ami_id" {}
variable instance_type {
  default = "t3-medium"
}

variable "entry_script" {}