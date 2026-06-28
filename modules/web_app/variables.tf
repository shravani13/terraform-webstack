variable "ami_id"{
        type = string
        description = "AMI ID of Amazon Linux machine"
}

variable "instance_type"{
        type = string
        description = "Instance type of Amazon Linux machine"
}

variable "private_cidr" {
  type = string
}
variable "private_subnet_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "key_name" {
  type = string
  description = "key pair created for ssh access"
}
