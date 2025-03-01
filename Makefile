# Makefile for LazyDev project
VERSION := 1.0.0
BUILD_TIME := $(shell date +%Y%m%d%H%M%S)
DIST_DIR := dist
BIN_DIR := $(DIST_DIR)/binaries
PKG_DIR := $(DIST_DIR)/pkg
INSTALLER_DIR := installer

.PHONY: all clean build-binaries build-images package installer

all: clean build-binaries build-images package

# 清理构建产物
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(DIST_DIR)/*
	rm -rf $(INSTALLER_DIR)
	docker rm -f temp-build || true
	docker rm -f temp-data-build || true

# 编译二进制文件
build-binaries:
	@echo "Building binaries..."
	mkdir -p $(BIN_DIR)
	
	# 编译 Windows 客户端
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 \
		go build -ldflags="-s -w" -o $(BIN_DIR)/lazydev.exe ./cmd/lazydev
	
	# 编译 Linux 守护进程
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 \
		go build -ldflags="-s -w" -o $(BIN_DIR)/lazyd ./cmd/lazyd

# 构建 Docker 镜像
build-images:
	@echo "Building Docker images..."
	
	# 构建 lazydev-desktop
	docker build -t lazydev-desktop:$(VERSION) -f docker/lazydev-desktop/openeuler/Dockerfile . 
	docker create --name temp-build lazydev-desktop:$(VERSION)
	docker export temp-build -o $(DIST_DIR)/lazydev-desktop.tar
	docker rm -f temp-build
	
	# 构建 lazydev-desktop-data
	docker build -t lazydev-desktop-data:$(VERSION) -f docker/lazydev-desktop-data/Dockerfile .
	docker create --name temp-data-build lazydev-desktop-data:$(VERSION)
	docker export temp-data-build -o $(DIST_DIR)/lazydev-desktop-data.tar
	docker rm -f temp-data-build

# 制作安装包
package:
	@echo "Packaging release..."
	mkdir -p $(PKG_DIR)
	
	# 复制必要文件
	cp -r $(BIN_DIR) $(PKG_DIR)
	cp $(DIST_DIR)/*.tar $(PKG_DIR)
	cp -r docker/lazydev-desktop/scripts $(PKG_DIR)
	
	# 创建版本文件
	echo "Version: $(VERSION)" > $(PKG_DIR)/VERSION
	echo "BuildTime: $(BUILD_TIME)" >> $(PKG_DIR)/VERSION
	
	# 制作 ZIP 包
	zip -jr $(DIST_DIR)/lazydev-$(VERSION).zip $(PKG_DIR)/*

# Windows 安装包 (需要预先安装 Inno Setup)
installer:
	@echo "Building Windows installer..."
	mkdir -p $(INSTALLER_DIR)
	
	# 生成安装脚本
	sed 's/{{VERSION}}/$(VERSION)/g' installer.template.iss > $(INSTALLER_DIR)/installer.iss
	
	# 检查 Inno Setup 是否安装
	@if ! command -v iscc >/dev/null; then \
		echo "Error: Inno Setup Compiler (iscc) not found"; \
		exit 1; \
	fi
	
	iscc $(INSTALLER_DIR)/installer.iss
	mv $(INSTALLER_DIR)/Output/setup.exe $(DIST_DIR)/lazydev-$(VERSION)-setup.exe
