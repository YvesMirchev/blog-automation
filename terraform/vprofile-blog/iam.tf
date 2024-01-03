## ---------------------------------------------------------------------------------------------------------------------
## IAM Policies and Roles
## ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "s3_artifact_copy_role" {
  name = "s3-artifact-copy-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "s3-full-access-policy"
  description = "Provides full access to S3"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access_attach" {
  role       = aws_iam_role.s3_artifact_copy_role.name
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

resource "aws_iam_instance_profile" "s3_artifact_copy_profile" {
  name = "s3-artifact-copy-profile"
  role = aws_iam_role.s3_artifact_copy_role.name
}
