resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.clusterrole.arn
  #version  = "1.31"

  vpc_config {
    subnet_ids              = flatten([aws_subnet.publicsubnets[*].id, aws_subnet.privatesubnets[*].id])
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-cluster"
    }
  )

  depends_on = [aws_iam_role_policy_attachment.clusterrole_policy_attach]
}

resource "aws_iam_role" "clusterrole" {
  name               = "${var.project_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-cluster-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "clusterrole_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.clusterrole.name
}

