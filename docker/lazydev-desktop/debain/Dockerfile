ARG VARIANT="bookworm"
FROM buildpack-deps:${VARIANT}-curl

COPY root-fs/ /

RUN apt-get update && apt-get install -y \
    vim \
    git \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*
