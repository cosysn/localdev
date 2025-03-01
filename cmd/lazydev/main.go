package main

import (
        "fmt"
        "os"

        "github.com/spf13/cobra"
        "github.com/cosysn/lazydev/pkg/installer"
)

var rootCmd = &cobra.Command{
	Use:   "lazydev",
	Short: "LazyDev 环境管理工具",
}

var installCmd = &cobra.Command{
	Use:   "install",
	Short: "安装 LazyDev 环境",
	Run: func(cmd *cobra.Command, args []string) {
		if err := installer.InstallEnvironment(); err != nil {
			fmt.Printf("安装失败: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("安装成功！")
	},
}

func init() {
	rootCmd.AddCommand(installCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
