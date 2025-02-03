# 使用最新版Alpine作为基础镜像
FROM alpine:3.21.2

# 将预配置的 root-fs 文件复制到镜像中
COPY root-fs/ /

# 安装基础软件包（包含openssh-server）
RUN apk update && \
    apk add --no-cache \
    vim \
    bash \
    git \
    python3 \
    docker \
    docker-cli \
    docker-compose \
    sudo \
    shadow \
    openssh-server \
    openrc && \
    # 确保关键目录权限正确
    chmod 755 /run && \
    rc-update add docker default && \
    rc-update add sshd default && \
    chmod +x /etc/init.d/lazydev && \
    rc-update add lazydev default && \
    # 清理缓存
    rm -rf /var/cache/apk/*

# 设置默认用户
USER root

# 设置容器启动时运行的命令
CMD ["/sbin/init"]
