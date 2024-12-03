# S3バケットの作成
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name 

  tags = {
    Name        = var.bucket_name
    Environment = "Development"
  }
}

# バケットACLの設定
resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# パブリックアクセスブロック設定の無効化
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership]
  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
}

# バケットポリシーの設定
resource "aws_s3_bucket_policy" "read_only_policy" {
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

# IAMユーザーの作成
resource "aws_iam_user" "read_only_user" {
  name = var.iam_user_name
}

# IAMポリシーの作成 (S3 Read-Only)
resource "aws_iam_policy" "s3_read_only_policy" {
  name        = "${var.iam_user_name}_S3ReadOnly"
  description = "Read-only access to the S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",     # 作成/更新
          "s3:GetObject",     # 読取
          "s3:DeleteObject",  # 削除
          "s3:ListBucket"     # バケット内のオブジェクト一覧表示
        ],
        Resource = [
          "${aws_s3_bucket.bucket.arn}",      # バケットへのアクセス
          "${aws_s3_bucket.bucket.arn}/*"     # バケット内のオブジェクトへのアクセス
        ]
      }
    ]
  })
}

# IAMポリシーをユーザーにアタッチ
resource "aws_iam_user_policy_attachment" "attach_read_only_policy" {
  user       = aws_iam_user.read_only_user.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

# IAMアクセスキーの作成
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.read_only_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.access_key.id
  sensitive = true
}

output "secret_access_key" {
  value = aws_iam_access_key.access_key.secret
  sensitive = true
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}
