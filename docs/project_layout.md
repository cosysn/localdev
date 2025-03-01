目录结构：
https://github.com/golang-standards/project-layout/


lazydev/
├── cmd/                       # Go 可执行程序入口
│   ├── lazyd/                 # 守护进程主程序
│   │   └── main.go
│   └── lazydev/               # Windows 主程序
│       └── main.go
├── pkg/                       # 共享代码库
│   ├── dockerctl/             # Docker 控制模块
│   ├── wslmgr/                # WSL 管理模块
│   └── monitor/               # 资源监控模块
├── docker/                    # Docker 构建相关
│   ├── lazydev-desktop/       # 主镜像构建文件
│   │   ├── Dockerfile
│   │   ├── scripts/           # 初始化脚本
│   │   │   └── init.sh
│   │   └── build.sh           # 专用构建脚本
│   └── lazydev-desktop-data/  # 数据镜像构建
│       ├── Dockerfile
│       └── build.sh
├── scripts/                   # 全局辅助脚本
│   ├── install-wsl.ps1        # Windows 安装脚本
│   └── build-all.sh           # 完整构建脚本
├── configs/                   # 配置文件
│   ├── lazyd.toml             # 守护进程配置
│   └── lazydev.yaml           # 客户端配置
├── dist/                      # 构建产物
│   ├── lazydev-desktop.tar    # 自动生成的镜像
│   ├── lazydev-desktop-data.tar
│   └── binaries/              # 编译后的可执行文件
├── docs/                      # 文档
│   ├── ARCHITECTURE.md
│   └── SETUP.md
├── test/                      # 测试相关
│   ├── integration/           # 集成测试
│   └── e2e/                   # 端到端测试
├── go.mod                     # Go 模块定义
├── Makefile                   # 构建自动化
└── .gitignore

