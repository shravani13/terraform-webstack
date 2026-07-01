module "network" {
  source        = "./modules/network"
  environment   = "prod"
  vpc_cidr      = "10.0.0.0/16"
  public_1_cidr = "10.0.1.0/24"
  private_cidr  = "10.0.2.0/24"
  public_2_cidr = "10.0.3.0/24"
  aws_region    = "us-east-1"
}

module "web_app" {
  source            = "./modules/web_app"
  environment       = "prod"
  instance_type     = "t3.small"
  ami_id            = "ami-08f44e8eca9095668"
  private_cidr      = "10.0.2.0/24"
  private_subnet_id = module.network.private_subnet
  public_subnet_ids = module.network.public_subnet_ids
  vpc_id            = module.network.vpc_id
  key_name          = "ec2-access"
}

# 1. Request the VPC Peering Connection
resource "aws_vpc_peering_connection" "public_to_private" {
  vpc_id      = "vpc-013c029b944d7961c" # The ID of your public server's VPC
  peer_vpc_id = module.network.vpc_id   # Your private server's VPC ID
  auto_accept = true                    # Automatically accepts since they are in the same account

  tags = { Name = "public-to-private-peering" }
}

# 2. Add a Route in the Public Server's Route Table pointing to the Private VPC Range
resource "aws_route" "from_public_vpc" {
  route_table_id            = "rtb-01bd85ad6186e760c"
  destination_cidr_block    = "10.0.0.0/16" # Your Private VPC's CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.public_to_private.id
}

# 3. Add a Route in your Private Server's Route Table pointing back to the Public VPC Range
resource "aws_route" "from_private_vpc" {
  route_table_id            = module.network.private_route_table_id
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.public_to_private.id
}
