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

#once s3 creation is done, needed to avoid from getting destroyed, so have to comment the code block of s3 - which is critical 