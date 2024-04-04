# create s3
/*
resource "aws_s3_bucket" "project_bucket"{
    bucket = "mca-project-bucket"
    versioning {
      enabled = true
    }
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
}
*/