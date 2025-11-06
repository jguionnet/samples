# AWS Configuration
aws_region = "us-west-2"

# S3 Bucket Configuration
bucket_name        = "tenant-atlantis-product-images"
enable_versioning  = false

# Environment
environment = "dev"
namespace   = "default"

# OIDC Provider (for IRSA) - Update these values for your cluster
# oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/EXAMPLE"
# oidc_provider_url = "oidc.eks.us-west-2.amazonaws.com/id/EXAMPLE"
