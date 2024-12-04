package infra

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
)

type BucketImpl struct {
	client *s3.Client
}

func NewBucketImpl() (*BucketImpl, error) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		return nil, fmt.Errorf("AWS設定の読み込みに失敗: %v", err)
	}

	return &BucketImpl{
		client: s3.NewFromConfig(cfg),
	}, nil
}

func (b *BucketImpl) GetBucket() error {
	output, err := b.client.ListBuckets(context.TODO(), &s3.ListBucketsInput{})
	if err != nil {
		return fmt.Errorf("S3バケットの一覧取得に失敗: %v", err)
	}

	fmt.Println("現在のS3バケット一覧:")
	for _, bucket := range output.Buckets {
		fmt.Printf("- 名前: %s, 作成日: %s\n", *bucket.Name, bucket.CreationDate)
	}
	return nil
}

// S3クライアントのモック
type mockS3Client struct {
	listBucketsOutput *s3.ListBucketsOutput
	err               error
}

func (m *mockS3Client) ListBuckets(ctx context.Context, params *s3.ListBucketsInput, optFns ...func(*s3.Options)) (*s3.ListBucketsOutput, error) {
	return m.listBucketsOutput, m.err
}

func TestBucketImpl_GetBucket(t *testing.T) {
	// テストケース
	testCases := []struct {
		name    string
		output  *s3.ListBucketsOutput
		err     error
		wantErr bool
	}{
		{
			name: "正常系",
			output: &s3.ListBucketsOutput{
				Buckets: []types.Bucket{
					{
						Name:         aws.String("test-bucket"),
						CreationDate: aws.Time(time.Now()),
					},
				},
			},
			wantErr: false,
		},
		{
			name:    "エラー系",
			output:  nil,
			err:     fmt.Errorf("模擬エラー"),
			wantErr: true,
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			// モックの準備
			mockClient := &mockS3Client{
				listBucketsOutput: tc.output,
				err:               tc.err,
			}

			// テスト対象のインスタンス作成
			b := &BucketImpl{
				client: mockClient,
			}

			// テスト実行
			err := b.GetBucket()

			// 結果確認
			if (err != nil) != tc.wantErr {
				t.Errorf("GetBucket() error = %v, wantErr %v", err, tc.wantErr)
			}
		})
	}
}
