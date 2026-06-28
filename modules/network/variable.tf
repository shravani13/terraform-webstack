variable "environment"{
	type = string
	description = "The deployment environment eg: dev,prod"
}

variable "vpc_cidr"{
	type = string
}

variable "private_cidr"{
	type = string
}

variable "public_1_cidr"{
	type = string
}

variable "public_2_cidr"{
  type = string
}

variable "aws_region"{
	type = string
}

