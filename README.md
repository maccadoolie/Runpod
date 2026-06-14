# RunPod vLLM S3 worker

This image wraps RunPod's vLLM serverless worker image and downloads a model from S3 into the worker at startup.

## What it builds

- Base image: `registry.runpod.net/runpod-workers-worker-vllm-main-dockerfile:1b3228a2d`
- Adds: `awscli`
- Entrypoint: syncs `MODEL_S3_URI` to `MODEL_NAME`, then hands off to the base worker command.

## Required GitHub secrets

Add these in GitHub:

`Settings` → `Secrets and variables` → `Actions` → `New repository secret`

The base vLLM worker image lives in RunPod's registry and requires registry auth during the GitHub Actions build.

Add these repository secrets:

- `RUNPOD_REGISTRY_USERNAME`
- `RUNPOD_REGISTRY_PASSWORD`

The workflow pushes the final image to GHCR using GitHub's built-in `GITHUB_TOKEN`.

After the first successful push, make the package visible to RunPod if needed:

1. Open GitHub → profile/packages → `runpod-vllm-s3`.
2. Package settings → change visibility to public, or configure RunPod with registry credentials for GHCR.

## Images pushed by GitHub Actions

On push to `main`, the workflow builds for `linux/amd64` and publishes:

- `ghcr.io/maccadoolie/runpod-vllm-s3:latest`
- `ghcr.io/maccadoolie/runpod-vllm-s3:sha-<commit>`

Use the SHA tag for reproducible RunPod endpoints once a build succeeds.

## Required RunPod endpoint environment variables

Set these on the RunPod serverless endpoint:

- `MODEL_S3_URI=s3://your-bucket/your-model-prefix/`
- `MODEL_NAME=/model`
- `AWS_REGION=ap-southeast-2` or your bucket region

The worker also needs AWS credentials with read access to the bucket. Configure them as RunPod endpoint environment variables or secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Optional if needed by your AWS setup:

- `AWS_SESSION_TOKEN`

## Deploy in RunPod

1. Open RunPod Console → Serverless.
2. Create or edit an endpoint.
3. Choose a custom container image.
4. Use one of the pushed image URLs, preferably a `sha-<commit>` tag.
5. Add the environment variables above.
6. Pick GPU type, worker count, and timeout.
7. Deploy and check worker logs for the S3 sync step.

## Common failures

- `MODEL_S3_URI is required`: endpoint env var missing.
- `MODEL_NAME is required`: endpoint env var missing; use `/model` unless the base worker expects another path.
- S3 `AccessDenied`: AWS credentials lack `s3:GetObject` / `s3:ListBucket` for the bucket/prefix.
- Image not found in RunPod: make the GHCR package public or add GHCR registry credentials in RunPod.
