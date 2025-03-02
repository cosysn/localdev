package installer

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

const (
	wslDesktopName     = "lazydev-desktop"
	wslDataName        = "lazydev-desktop-data"
	defaultInstallPath = "C:\\WSL\\LazyDev"
)

func InstallEnvironment() error {
	// 检查必要文件
	if err := checkRequiredFiles(); err != nil {
		return err
	}

	// 检查 WSL 是否已安装
	if err := checkWSLInstalled(); err != nil {
		return fmt.Errorf("WSL 未安装或未启用: %w", err)
	}

	// 检查并创建 wsl 目录
	if err := ensureWSLDir(); err != nil {
		return fmt.Errorf("无法创建 WSL 目录: %w", err)
	}

	// 导入 WSL 镜像
	if err := importWslDistros(); err != nil {
		return err
	}

	// 初始化环境
	if err := initializeEnvironment(); err != nil {
		return err
	}

	return nil
}

// 检查 WSL 是否已安装
func checkWSLInstalled() error {
	cmd := exec.Command("wsl", "--list", "--quiet")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("WSL 未安装或未启用")
	}
	return nil
}

// 检查并创建 wsl 目录
func ensureWSLDir() error {
	// 获取当前可执行文件路径
	exePath, err := os.Executable()
	if err != nil {
		return fmt.Errorf("无法获取可执行文件路径: %w", err)
	}
	baseDir := filepath.Dir(exePath)

	// 定义 wsl 目录路径
	wslDir := filepath.Join(baseDir, "wsl")

	// 检查目录是否存在
	if _, err := os.Stat(wslDir); os.IsNotExist(err) {
		fmt.Printf("创建 WSL 目录: %s\n", wslDir)
		if err := os.Mkdir(wslDir, 0755); err != nil {
			return fmt.Errorf("创建目录失败: %w", err)
		}
	} else if err != nil {
		return fmt.Errorf("检查目录失败: %w", err)
	}

	return nil
}

func getInstallBasePath() (string, error) {
	// 获取当前可执行文件路径
	exePath, err := os.Executable()
	if err != nil {
		return "", fmt.Errorf("无法获取可执行文件路径: %w", err)
	}

	// 转换路径格式（处理可能的符号链接）
	exePath, err = filepath.EvalSymlinks(exePath)
	if err != nil {
		return "", fmt.Errorf("路径解析失败: %w", err)
	}

	// 确定基础路径：可执行文件所在目录下的 wsl 子目录
	baseDir := filepath.Join(filepath.Dir(exePath), "wsl")

	// 验证路径有效性
	if strings.ContainsAny(baseDir, ";&%$") {
		return "", fmt.Errorf("路径包含非法字符: %s", baseDir)
	}

	return baseDir, nil
}

func checkRequiredFiles() error {
	requiredFiles := []string{
		"lazydev-desktop.tar",
		"lazydev-desktop-data.tar",
	}

	exePath, err := os.Executable()
	if err != nil {
		return fmt.Errorf("无法获取可执行文件路径: %w", err)
	}
	appDir := filepath.Dir(exePath)

	for _, file := range requiredFiles {
		path := filepath.Join(appDir, file)
		if _, err := os.Stat(path); os.IsNotExist(err) {
			return fmt.Errorf("缺失必要文件: %s", file)
		}
	}
	return nil
}

// 检查 WSL 分发版是否存在
func wslDistroExists(name string) bool {
	cmd := exec.Command("wsl", "-l", "--quiet")
	output, err := cmd.Output()
	if err != nil {
		return false
	}

	// 清理输出：移除空字符和换行符
	cleanedOutput := strings.Map(func(r rune) rune {
		if r == 0 || r == '\r' {
			return -1 // 移除这些字符
		}
		return r
	}, string(output))

	lines := strings.Split(cleanedOutput, "\n")
	for _, line := range lines {
		// 去除前后空格并检查完全匹配
		cleanedLine := strings.TrimSpace(line)
		if cleanedLine == name {
			return true
		}
	}
	return false
}

func importWslDistros() error {
	// 获取动态安装路径
	basePath, err := getInstallBasePath()
	if err != nil {
		return err
	}

	// 检查并导入 Desktop 镜像
	desktopPath := filepath.Join(basePath, wslDesktopName)
	fmt.Println("正在导入到 %s", desktopPath)
	if !wslDistroExists(wslDesktopName) {
		fmt.Println("正在导入 lazydev-desktop...")
		tarPath := filepath.Join(filepath.Dir(basePath), "lazydev-desktop.tar")
		cmd := exec.Command("wsl", "--import", wslDesktopName,
			desktopPath,
			tarPath, "--version", "2")
		if output, err := cmd.CombinedOutput(); err != nil {
			return fmt.Errorf("导入失败: %s\n%s", err, string(output))
		}
	} else {
		fmt.Println("lazydev-desktop 已存在，跳过导入")
	}

	// 检查并导入 Data 镜像
	desktopDataPath := filepath.Join(basePath, wslDataName)
	fmt.Println("正在导入到 %s", desktopDataPath)
	if !wslDistroExists(wslDataName) {
		fmt.Println("正在导入 lazydev-desktop-data...")
		tarPath := filepath.Join(filepath.Dir(basePath), "lazydev-desktop-data.tar")
		cmd := exec.Command("wsl", "--import", wslDataName,
			desktopDataPath,
			tarPath, "--version", "2")
		if output, err := cmd.CombinedOutput(); err != nil {
			return fmt.Errorf("导入失败: %s\n%s", err, string(output))
		}
	} else {
		fmt.Println("lazydev-desktop-data 已存在，跳过导入")
	}

	return nil
}

func initializeEnvironment() error {
	fmt.Println("正在初始化环境...")
	cmd := exec.Command("wsl", "-d", wslDesktopName, "bash /opt/lazydev/scripts/init.sh")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
