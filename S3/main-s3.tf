# module for creating the tranist bucket and role that can be associated to an AWS instance, such as cloudwatch
# or EC2

variable "app_name" {}
variable "app_environment" {}
variable "region" {}

# workaround for -gov regions
locals {
  arn = can(regex("-gov-", var.region)) ? "aws-us-gov" : "aws"
}

# create the bucket
resource "aws_s3_bucket" "transit_bucket" {
  bucket = "transittest"
  # comment out the following line
  force_destroy = true
  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-s3-transit"
    Environment = var.app_environment
  }

}

# remove any default access to the bucket
resource "aws_s3_bucket_public_access_block" "transit_bucket_access" {
  bucket = aws_s3_bucket.transit_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

# define a policy for the bucket
resource "aws_iam_policy" "transit_policy" {
  name        = "transit-policy"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:${local.arn}:s3:::*/*",
          "arn:${local.arn}:s3:::transit"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "transit_role" {
  name = "transit"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_group" "transit_user_group" {
  name = "TransitUsers"
}

resource "aws_iam_group_policy_attachment" "transit_group_policy" {
  group      = aws_iam_group.transit_user_group.name
  policy_arn = aws_iam_policy.transit_policy.arn
}

resource "aws_iam_role_policy_attachment" "transit_policy" {
  role       = aws_iam_role.transit_role.name
  policy_arn = aws_iam_policy.transit_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloud_watch_policy" {
  role       = aws_iam_role.transit_role.name
  policy_arn = "arn:${local.arn}:iam::aws:policy/CloudWatchAgentServerPolicy"
}

output "transit_role_name" {
  value = aws_iam_role.transit_role.name
}
