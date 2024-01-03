resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "vprofile-artifact-dev"

  tags = {
    Name        = "ArtifactBucketDev"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_versioning" "versioning_artifact_bucket" {
  bucket = aws_s3_bucket.artifact_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
