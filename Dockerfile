FROM runpod/worker-v1-vllm:v2.22.4

RUN apt-get update && apt-get install -y awscli && rm -rf /var/lib/apt/lists/*

COPY rp_entrypoint.sh /rp_entrypoint.sh
RUN chmod +x /rp_entrypoint.sh

ENTRYPOINT ["/rp_entrypoint.sh"]
