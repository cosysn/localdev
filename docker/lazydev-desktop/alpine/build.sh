#!/bin/bash

# 脚本功能：
# 1. 将所有文件使用 dos2unix 转格式；
# 2. 给文件赋予正确的权限；
# 3. 检查 Docker 是否有 lazydev-desktop 的镜像，如果有则删除；
# 4. 制作一个名为 lazydev-desktop 的镜像，使用当前目录的 Dockerfile。

# 检查是否安装了 dos2unix
if ! command -v dos2unix &> /dev/null; then
    echo "dos2unix 未安装，请先安装 dos2unix。"
    exit 1
fi

# 1. 将所有文件使用 dos2unix 转格式
echo "正在转换文件格式为 Unix 格式..."
find . -type f -exec dos2unix {} \;

# 2. 给文件赋予正确的权限
echo "正在设置文件权限..."
find . -type f -exec chmod 644 {} \;  # 文件权限设置为 644
find . -type d -exec chmod 755 {} \;  # 目录权限设置为 755

# 3. 检查 Docker 是否有 lazydev-desktop 的镜像，如果有则删除
IMAGE_NAME="lazydev-desktop"
if docker image inspect "$IMAGE_NAME" &> /dev/null; then
    echo "发现已存在的镜像 $IMAGE_NAME，正在删除..."
    docker rmi -f "$IMAGE_NAME"
else
    echo "未找到镜像 $IMAGE_NAME，跳过删除步骤。"
fi

# 4. 制作一个名为 lazydev-desktop 的镜像，使用当前目录的 Dockerfile
echo "正在构建 Docker 镜像 $IMAGE_NAME..."
docker build -t "$IMAGE_NAME" .

docker run -t --name lazydev-desktop-export lazydev-desktop ls /
docker export lazydev-desktop-export > ./lazydev-tmp.tar
docker rm lazydev-desktop-export

echo "脚本执行完毕！"
