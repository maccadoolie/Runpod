#!/usr/bin/env bash
set -euo pipefail

: "${MODEL_S3_URI:?MODEL_S3_URI is required (s3://bucket/prefix/)}"
: "${MODEL_NAME:?MODEL_NAME is required (local path like /model)}"
: "${AWS_REGION:?AWS_REGION is required (e.g. ap-southeast-2)}"

echo "Syncing model from S3: ${MODEL_S3_URI} -> ${MODEL_NAME}"
aws s3 sync "$MODEL_S3_URI" "$MODEL_NAME" --region "$AWS_REGION"

echo "Handing off to base vLLM worker CMD..."
exec "$@"
