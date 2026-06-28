terraform {
	required_version = ">1.5.0"
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~>5.0"
		}
	}

backend "s3" {
	bucket = "terraform-s3-bucket-5292"
	key = "prod/web_stack/terraform.tfstate"
	dynamodb_table = "terraform-state-dynamodb-table-lock"
	region = "us-east-1"
}
}

