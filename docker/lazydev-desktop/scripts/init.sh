# docker/lazydev-desktop/scripts/init.sh
#!/bin/bash

# 启动 Docker 服务
if [ ! "$(pgrep dockerd)" ]; then
    sudo service docker start
fi

# 配置自动启动
sudo tee /etc/profile.d/lazydev-init.sh >/dev/null <<EOF
#!/bin/sh
if [ ! "$(pgrep lazyd)" ]; then
    /usr/local/bin/lazyd > /var/log/lazyd.log 2>&1 &
fi
EOF

# 创建数据卷链接
if [ ! -d "/data" ]; then
    sudo mkdir /data
    sudo mount --bind /mnt/wsl/lazydev-desktop-data/data /data
fi

# 启动守护进程
nohup /usr/local/bin/lazyd > /dev/null 2>&1 &
