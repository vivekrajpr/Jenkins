provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "webhost" {
    bucket = var.bucketname

    }

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.webhost.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership]

  bucket = aws_s3_bucket.webhost.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.webhost.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "accessblock" {
    bucket = aws_s3_bucket.webhost.id

    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}
   
resource "aws_s3_bucket_acl" "bucketacl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.accessblock,
  ]

  bucket = aws_s3_bucket.webhost.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
    
  bucket = aws_s3_bucket.webhost.id
  key = "index.html"
  source = "/root/testprojects/index.html"
  acl = "public-read"
}

resource "aws_s3_object" "error" {
    
  bucket = aws_s3_bucket.webhost.id
  key = "error.html"
  source = "/root/testprojects/error.html"
  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.webhost.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.bucketacl ]
}
