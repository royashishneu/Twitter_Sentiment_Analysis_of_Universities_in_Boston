data "aws_s3_bucket" "codedeploy" {
  bucket = "codedeploy.csye7200.xyz"
}

resource "aws_iam_role" "CodeDeployServiceRole" {
  name = "CodeDeployServiceRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codedeploy.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "CodeDeploy-EC2-S3" {
  name        = "CodeDeploy-EC2-S3"
  path        = "/"
  description = "CodeDeploy-EC2-S3"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Action" : [
          "s3:Get*",
          "s3:List*"
        ],
        "Effect" : "Allow",
        "Resource" : ["arn:aws:s3:::${data.aws_s3_bucket.codedeploy.bucket}", "arn:aws:s3:::${data.aws_s3_bucket.codedeploy.bucket}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole-attach" {
  role = aws_iam_role.CodeDeployServiceRole.name
  # AWSCodeDeployRole policy
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "csye7200-webapp" {
  compute_platform = "Server"
  name             = "csye7200-webapp"
}

resource "aws_codedeploy_deployment_group" "csye7200-webapp-deployment" {
  app_name              = aws_codedeploy_app.csye7200-webapp.name
  deployment_group_name = "csye7200-webapp-deployment"
  service_role_arn      = aws_iam_role.CodeDeployServiceRole.arn
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "webapp"
    }
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

resource "aws_iam_role_policy_attachment" "CodeDeploy-S3-attach" {
  role = aws_iam_role.webapp_role.name
  # AWSCodeDeployRole policy
  policy_arn = aws_iam_policy.CodeDeploy-EC2-S3.arn
}