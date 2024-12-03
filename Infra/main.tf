provider "aws" {
  alias  = "ap_northeast_1"
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "ap-northeast-3"
  region = "ap-northeast-3"
}

module "s3_iam_ap_northeast_1" {
  source       = "./modules/s3_iam"
  providers    = {
    aws = aws.ap_northeast_1
  }
  region       = "ap-northeast-1"
  bucket_name  = "juntendou1390-bucket-ap-northeast-1"
  iam_user_name = "cli-iam-user-ap-northeast-1"
}

module "s3_iam_ap_northeast_3" {
  source       = "./modules/s3_iam"
  providers    = {
    aws = aws.ap-northeast-3
  }
  region       = "ap-northeast-3"
  bucket_name  = "juntendou1390-bucket-ap-northeast-3"
  iam_user_name = "cli-iam-user-ap-northeast-3"
}
