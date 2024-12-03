output "ap_northeast_1_access_key" {
  value = module.s3_iam_ap_northeast_1.access_key_id
}

output "ap_northeast_3_access_key" {
  value = module.s3_iam_ap_northeast_3.access_key_id
}

output "ap_northeast_1_secret_access_key" {
  value = module.s3_iam_ap_northeast_1.secret_access_key
  sensitive = true
}

output "ap_northeast_3_secret_access_key" {
  value = module.s3_iam_ap_northeast_3.secret_access_key
  sensitive = true
}

output "bucket_names" {
  value = [
    module.s3_iam_ap_northeast_1.bucket_name,
    module.s3_iam_ap_northeast_3.bucket_name
  ]
}
