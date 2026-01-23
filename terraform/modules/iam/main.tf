# Data source to fetch existing role if create_role is false
data "aws_iam_role" "existing" {
  count = var.create_role ? 0 : 1
  name  = var.existing_role_name
}

resource "aws_iam_role" "ec2_ecr_role" {
  count       = var.create_role ? 1 : 0
  name_prefix = "nexgensis-ec2-ecr-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  count      = var.create_role ? 1 : 0
  role       = aws_iam_role.ec2_ecr_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "nexgensis-ec2-profile-"
  role        = var.create_role ? aws_iam_role.ec2_ecr_role[0].name : data.aws_iam_role.existing[0].name
}
