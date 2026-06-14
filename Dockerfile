FROM registry.runpod.net/runpod-workers-worker-vllm-main-dockerfile:1b3228a2d

RUN apt-get update && apt-get install -y awscli && rm -rf /var/lib/apt/lists/*

COPY rp_entrypoint.sh /rp_entrypoint.sh
RUN chmod +x /rp_entrypoint.sh

ENTRYPOINT ["/rp_entrypoint.sh"]
