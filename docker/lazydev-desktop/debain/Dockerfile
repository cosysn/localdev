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
    && rm -rf /var/lib/apt/lists/* \
    && cp /lib/systemd/system/docker.service /etc/systemd/system/ \
    && sed -i 's/\ -H\ fd:\/\//\ -H\ fd:\/\/\ -H\ tcp:\/\/127.0.0.1:2375/g' /etc/systemd/system/docker.service
