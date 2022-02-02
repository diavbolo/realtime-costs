
output "artifact_bucket" {
  value = aws_s3_bucket.build_artifact_bucket.id
}

output "codepipeline_role" {
  value = aws_iam_role.codepipeline_role.arn
}

output "codepipeline_role_name" {
  value = aws_iam_role.codepipeline_role.id
}

output "codebuild_role" {
  value = aws_iam_role.codebuild_assume_role.arn
}

output "codebuild_role_name" {
  value = aws_iam_role.codebuild_assume_role.id
}

