data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "s3bucket" {
  bucket        = "${var.business-unit}-${var.team_name}-${var.bucket_identifier}"
  acl           = "${var.acl}"
  force_destroy = "true"
  region        = "${data.aws_region.current.name}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = "${var.versioning}"
  }

  tags {
    business-unit          = "${var.business-unit}"
    application            = "${var.application}"
    is-production          = "${var.is-production}"
    environment-name       = "${var.environment-name}"
    owner                  = "${var.team_name}"
    infrastructure-support = "${var.infrastructure-support}"
  }
}

resource "random_id" "user" {
  byte_length = 8
}

resource "aws_iam_user" "s3-account" {
  name = "s3-bucket-user-${random_id.user.hex}"
  path = "/system/s3-bucket-user/${var.team_name}/"
}

resource "aws_iam_access_key" "s3-account-access-key" {
  user = "${aws_iam_user.s3-account.name}"
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:GetBucketTagging",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:ListBucketVersions",
      "s3:GetBucketLogging",
      "s3:RestoreObject",
      "s3:ReplicateObject",
      "s3:GetObjectVersionTorrent",
      "s3:GetObjectAcl",
      "s3:GetEncryptionConfiguration",
      "s3:AbortMultipartUpload",
      "s3:GetBucketRequestPayment",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
      "s3:GetIpConfiguration",
      "s3:DeleteObjectTagging",
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketWebsite",
      "s3:PutObjectVersionTagging",
      "s3:DeleteObjectVersionTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketNotification",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectTorrent",
      "s3:GetBucketCORS",
      "s3:GetObjectVersionForReplication",
      "s3:GetBucketLocation",
      "s3:ReplicateDelete",
      "s3:GetObjectVersion",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.s3bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.s3bucket.bucket}/*",
    ]
  }
}

resource "aws_iam_user_policy" "policy" {
  name   = "s3-bucket-read-write"
  policy = "${data.aws_iam_policy_document.policy.json}"
  user   = "${aws_iam_user.s3-account.name}"
}
