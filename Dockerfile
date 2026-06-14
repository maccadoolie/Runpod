FROM registry.runpod.net/runpod-workers-worker-vllm-main-dockerfile:1b3228a2d

# Ensure AWS CLI exists (some base images already have it; this makes it explicit)
RUN apt-get update && apt-get install -y awscli && rm -rf /var/lib/apt/lists/*

RUN if [ -f /start.sh ]; then mv /start.sh /start.sh.original; fi
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
