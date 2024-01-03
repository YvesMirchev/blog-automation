terraform {
  backend "s3" {
    bucket = "vprofile-blog-state" # Change this name of the bucket as you wish
    key    = "terraform/blog-dev"  # Same goes for the name of the state file
    region = "us-east-1"           # Change the region as well
  }
}
