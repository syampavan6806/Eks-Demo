desired_size = 1
min_size = 1
max_size = 2
vpc_cidr = "10.1.0.0/16"
public_subnet_cidrs = ["10.1.0.0/19", "10.1.32.0/19", "10.1.64.0/19"]
private_subnet_cidrs = ["10.1.96.0/19", "10.1.128.0/19", "10.1.160.0/19"]
instance_types = ["t2.micro"]
project_name = "Demo-Eks-QA"
common-tags = {"Environment" = "QA", "owner" = "MSA-solutions"}
