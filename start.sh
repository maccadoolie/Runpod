#!/usr/bin/env bash
set -euo pipefail

: "${MODEL_S3_URI:?MODEL_S3_URI is required}"
: "${MODEL_NAME:?MODEL_NAME is required}"
: "${AWS_REGION:?AWS_REGION is required}"

echo "Syncing model from S3: $MODEL_S3_URI -> $MODEL_NAME"
aws s3 sync "$MODEL_S3_URI" "$MODEL_NAME" --region "$AWS_REGION"

echo "Starting vLLM..."
# Hand off to the original container's command
exec /start.sh.original 2>/dev/null || exec "$@"
