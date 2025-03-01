开发一个全容器开发环境：


lazydev-desktop镜像
1 使用Dockerfile构建wsl镜像，基于openeuler制作；
2 安装Docker；
3 在构建的时候，将lazyd直接制作到镜像中
4 构建的时候，将这个镜像导出为lazydev-desktop.tar

lazydev-desktop-data镜像
1 使用Dockerfile构建wsl镜像，基于alpine构建；
2 创建/data目录用来存放用户数据；
3 构建的时候，将这个镜像导出为lazydev-desktop-data.tar

lazyd守护进程
1 运行在wsl的lazydev-desktop虚拟机中
2 负责管理docker容器
3 监控wsl虚拟机的状态，如docker异常，cpu过高等
4 支持制作开发容器
5 使用go语言开发

lazydev进程
1 使用go语言开发
2 运行在windows中
3 启动的时候，会检查wsl中是否存在lazydev-desktop和lazydev-desktop-data虚拟机，如果没有的话，则启动安装流程
   a 使用lazydev-desktop.tar导入为lazydev-desktop虚拟机
   b 使用lazydev-desktop-data.tar导入为lazydev-desktop-data虚拟机
   c 启动lazydev-desktop虚拟机，并执行/opt/lazydev/scritps/init.sh脚本进行初始化
4 启动lazyd服务
5 和lazyd服务建链，完成容器化开发环境的管理工作

