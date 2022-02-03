

resource "aws_codedeploy_app" "csye7200-spark" {
  compute_platform = "Server"
  name             = "csye7200-spark"
}

resource "aws_codedeploy_deployment_group" "csye7200-spark-deployment" {
  app_name              = aws_codedeploy_app.csye7200-spark.name
  deployment_group_name = "csye7200-spark-deployment"
  service_role_arn      = aws_iam_role.CodeDeployServiceRole.arn
  #autoscaling_groups    = ["${aws_autoscaling_group.asg_spark.name}"]
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "spark"
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