
module "codecommit-cicd" {
  source                    = "./modules/terraform-aws-codecommit-cicd"
  repo_name                 = local.airflow_name
  organization_name         = local.airflow_name
  repo_default_branch       = var.airflow_git_branch
  aws_region                = var.region
  char_delimiter            = "-"
  environment               = "dev"
  build_timeout             = "5"
  build_compute_type        = "BUILD_GENERAL1_SMALL"
  build_image               = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  build_privileged_override = "false"
  test_buildspec            = "buildspec_test.yml"
  package_buildspec         = "buildspec.yml"
  force_artifact_destroy    = "true"
  destination_bucket        = aws_s3_bucket.s3_bucket_airflow.arn
  git_repository            = var.airflow_git_repository
  git_codestar              = aws_codestarconnections_connection.git.arn
}

resource "aws_codestarconnections_connection" "git" {
  name          = local.git_name
  provider_type = "GitHub"
}
