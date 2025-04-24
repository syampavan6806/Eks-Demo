variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "This AWS region in which terraform will manage the infrastructure "

}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "vpc cidr"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]

}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]

}

variable "project_name" {
  type    = string
  default = "Eks-Demo"

}

variable "desired_size" {
  type = number
  default = 2
  
}

variable "min_size" {
  type = number
  default = 2
  
}

variable "max_size" {
type = number
default = 10 
}

variable "instance_types"{
type = list(string)
default = ["t2.micro"]
}


variable "common-tags" {
  type = map(string)
  default = {
    "Environment" = "Dev"
    "owner"       = "MSA-Solutions"
  }

}

variable "eks_node_role_policies" {
  type = set(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}