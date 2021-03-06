provider "aws" {
  region = "eu-central-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

variable "cluster_name" {
  default = "my-cluster"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "k8s-${var.cluster_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "14.0.0"
  cluster_name    = "eks-${var.cluster_name}"
  cluster_version = "1.18"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name = "worker-group-1"
      root_volume_type = "gp2"
      instance_type = "m4.large"
      asg_max_size  = 5
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name = "worker-group-2"
      root_volume_type = "gp2"
      instance_type = "t2.small"
      asg_max_size  = 5
      asg_desired_capacity = 1
      asg_max_size = 3
      asg_min_size = 0
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
    }
  ]

  write_kubeconfig   = true
  config_output_path = "./"
}
