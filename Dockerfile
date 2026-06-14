FROM runpod/worker-v1-vllm:v2.22.4

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=Etc/UTC

RUN apt-get update \
	&& apt-get install -y --no-install-recommends awscli tzdata \
	&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
	&& echo $TZ > /etc/timezone \
	&& rm -rf /var/lib/apt/lists/*

COPY rp_entrypoint.sh /rp_entrypoint.sh
RUN chmod +x /rp_entrypoint.sh

ENTRYPOINT ["/rp_entrypoint.sh"]
