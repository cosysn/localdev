#!/bin/sh

# 从 USERPROFILE 环境变量中提取 Windows 用户名
WINDOWS_HOME_DIR=$(wslpath "$(wslvar HOME)")


# 输出结果
echo "当前 Windows 用户名: $WINDOWS_HOME_DIR"

# 定义 Windows 主机的 .ssh 目录路径
WINDOWS_SSH_DIR="${WINDOWS_HOME_DIR}/.ssh"
WINDOWS_GLOBAL_CONFIG="${WINDOWS_HOME_DIR}/.gitconfig"
# 定义 Alpine 中的 .ssh 目录路径
ALPINE_SSH_DIR="$HOME/.ssh"

# 检查 Windows 的 .ssh 目录是否存在
if [ ! -d "$WINDOWS_SSH_DIR" ]; then
  echo "错误：未找到 Windows 的 .ssh 目录：$WINDOWS_SSH_DIR"
  exit 1
fi

# 创建 Alpine 的 .ssh 目录（如果不存在）
mkdir -p "$ALPINE_SSH_DIR"

# 拷贝 Windows 的 .ssh 文件到 Alpine
echo "正在拷贝 .ssh 文件..."
cp -r "$WINDOWS_SSH_DIR"/* "$ALPINE_SSH_DIR"/
cp -r "$WINDOWS_GLOBAL_CONFIG" "$HOME"/

# 设置正确的文件权限
echo "设置文件权限..."
chmod 700 "$ALPINE_SSH_DIR"
chmod 600 "$ALPINE_SSH_DIR"/id_rsa
chmod 644 "$ALPINE_SSH_DIR"/id_rsa.pub
if [ -f "$ALPINE_SSH_DIR/config" ]; then
  chmod 600 "$ALPINE_SSH_DIR"/config
fi


# 配置 Git 使用 SSH
echo "配置 Git 使用 SSH..."
if ! command -v git &> /dev/null; then
  echo "Git 未安装，正在安装 Git..."
  apk add git
fi

echo "Git 配置完成："
git config --global --list

echo "脚本执行完毕！"