package infra

import "github.com/aws/aws-sdk-go-v2/service/s3/types"

type BucketGetter interface {
	GetBucket() ([]types.Bucket, error)
}
