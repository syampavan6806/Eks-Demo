resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.project_name
  node_role_arn   = aws_iam_role.noderole.arn
  subnet_ids      = aws_subnet.privatesubnets[*].id

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  ami_type       = "AL2_x86_64"
  disk_size      = 20
  capacity_type  = "ON_DEMAND"
  instance_types = var.instance_types
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name Eks-Demo-cluster --region ap-south-1 --profile terraformprofile"
    on_failure = continue
  }
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-node-group"
    }
  )
  depends_on = [aws_iam_role_policy_attachment.noderole_policy_attach]
}

resource "aws_iam_role" "noderole" {
  name               = "${var.project_name}-worker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_node.json
  tags = merge(var.common-tags,
    {
      "Name" = "${var.project_name}-worker-role"
  })
}

resource "aws_iam_role_policy_attachment" "noderole_policy_attach" {
  for_each   = var.eks_node_role_policies
  role       = aws_iam_role.noderole.name
  policy_arn = each.value

}
