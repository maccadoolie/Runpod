# RunPod vLLM S3 worker

This image wraps RunPod's vLLM serverless worker image and downloads a model from S3 into the worker at startup.

## What it builds

- Base image: `registry.runpod.net/runpod-workers-worker-vllm-main-dockerfile:1b3228a2d`
- Adds: `awscli`
- Entrypoint: syncs `MODEL_S3_URI` to `MODEL_NAME`, then hands off to the base worker command.

## Recommended deploy path: RunPod GitHub integration

Use RunPod's own GitHub integration for this repository. This avoids GitHub Actions needing to log into RunPod's private registry to pull the base worker image.

1. Open RunPod Console → Settings → Connections → GitHub → Connect.
2. Allow RunPod access to this repository: `maccadoolie/Runpod`.
3. Open RunPod Console → Serverless → New Endpoint.
4. Choose `Import Git Repository`.
5. Select repository: `maccadoolie/Runpod`.
6. Branch: `main`.
7. Dockerfile path: `Dockerfile`.
8. Configure GPU, workers, timeout, and endpoint environment variables below.
9. Deploy and watch the endpoint `Builds` tab.

RunPod builds the image inside its own builder and can access its own base worker image. GitHub Actions usually cannot pull that private base image unless you have separate RunPod registry credentials.

## Optional GitHub Actions path

The GitHub Actions workflow is manual-only and optional. It exists only if you have working RunPod registry credentials that can pull the private base image from `registry.runpod.net`.

Add these in GitHub if you want to use Actions:

`Settings` → `Secrets and variables` → `Actions` → `New repository secret`

`Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Required for GitHub Actions builds:

- `RUNPOD_REGISTRY_USERNAME`
- `RUNPOD_REGISTRY_PASSWORD`

If these credentials produce `401 Unauthorized`, do not keep fighting GitHub Actions. Use the recommended RunPod GitHub integration above.

When it works, the workflow pushes the final image to GHCR using GitHub's built-in `GITHUB_TOKEN`.

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

## Deploy from a prebuilt GHCR image

Only use this path if the optional GitHub Actions workflow successfully published a GHCR image.

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
