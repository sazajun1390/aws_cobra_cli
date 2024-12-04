package infra

import (
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
)

type BucketImpl struct {
}

func (b *BucketImpl) getBucket() ([]types.Bucket, error) {
	// AWS設定を読み込む
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		//log.Fatalf("AWS設定の読み込みに失敗しました: %v", err)
		return nil, err
	}

	// S3クライアントを作成
	client := s3.NewFromConfig(cfg)

	// S3バケット一覧を取得
	output, err := client.ListBuckets(context.TODO(), &s3.ListBucketsInput{})
	if err != nil {
		//log.Fatalf("S3バケットの一覧取得に失敗しました: %v", err)
		return nil, err
	}

	// バケット情報を出力
	fmt.Println("現在のS3バケット一覧:")
	for _, bucket := range output.Buckets {
		fmt.Printf("- 名前: %s, 作成日: %s\n", *bucket.Name, bucket.CreationDate)
	}
	return output.Buckets, nil
}
