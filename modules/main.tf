# AWS Provider
provider "aws" {
  region = "${var.region}"
}

# Variables for VPC
module "vpc" {
  source       = "./vpc"
  environment  = "dev"
  vpc_cidr     = "10.74.0.0/16"
  public_cidr  = ["10.74.1.0/24", "10.74.2.0/24"]
  private_cidr = ["10.74.3.0/24", "10.74.4.0/24"]
}

# Variables for EC2
module "ec2" {
  source         = "./ec2"
  environment    = "dev"
  public_key     = "C:\\Users\\patelax\\Documents\\GitHub\\terraform\\modules\\ec2\\id_rsa.pub"
  instance_type  = "t2.micro"
  security_group = "${module.vpc.security_group}"
  subnets        = "${module.vpc.private_subnet}"
}

# Variables for ELB
module "elb" {
  source         = "./elb"
  environment    = "dev"
  vpc_id         = "${module.vpc.vpc_id}"
  instance1_id   = "${module.ec2.instance1_id}"
  instance2_id   = "${module.ec2.instance2_id}"
  public_subnet1 = "${module.vpc.public_subnet1}"
  public_subnet2 = "${module.vpc.public_subnet2}"
}

# Variables for Auto-Scaling
module "auto_scaling" {
  source           = "./auto_scaling"
  environment      = "dev"
  ami              = "${module.ec2.ami}"
  vpc_id           = "${module.vpc.vpc_id}"
  public_subnet1   = "${module.vpc.public_subnet1}"
  public_subnet2   = "${module.vpc.public_subnet2}"
  target_group_arn = "${module.elb.elb_target_group_arn}"
}

# Variable for RDS
module "rds" {
  source      = "./rds"
  environment = "dev"
  db_instance = "db.t2.micro"
  rds_subnet1 = "${module.vpc.private_subnet1}"
  rds_subnet2 = "${module.vpc.private_subnet2}"
  vpc_id      = "${module.vpc.vpc_id}"
}

