terraform {
  backend "s3" {
    bucket         = "my-terraform-project-3"
    key            = "backend/terraform-project-3.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-terraform-project-3-dynamodb-table"
  }
}

#DynamoDB for State Locking: When multiple users or processes run Terraform commands simultaneously, it can lead to conflicts and corruption of the state file. DynamoDB provides a "lock" mechanism to prevent this. By setting up a DynamoDB table, Terraform can ensure that only one operation can modify the state at a time, reducing the risk of errors.
#S3 Backend: Terraform uses a "state file" to keep track of your infrastructure's current state. By storing this state file in an S3 bucket, you ensure that it's centralized, versioned, and accessible from anywhere. This is especially important in a team environment, where multiple people might be working on the same infrastructure.