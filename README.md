# 🐱🐱 Clash Linux

此项目是通过使用开源项目 [Clash](https://github.com/Dreamacro/clash) 作为核心程序，再结合脚本实现简单的代理功能。

项目是 fork 了 [原项目链接](https://github.com/wnlen/clash-for-linux)的项目进行的修改。

主要是为了解决我们在服务器上下载 GitHub 等一些国外资源时速度慢的问题。

---

## 📝 修改说明

这是 [Clash Linux](https://github.com/pldz1/clash-linux) 项目的定制版本，做了如下修改：

- **清空环境变量**：项目中的所有环境变量已被置空，用户可以根据自己的需求进行手动配置。
- **UI 修复**：修复了空的 URL 导致 UI 无法加载的问题，现在即使 URL 为空，UI 也能够正常启动和使用。

- **脚本重组**：

  - 去掉了根目录下的 `start.sh`、`shutdown.sh` 和 `restart.sh` 脚本。
  - 这些脚本已被移至 `script/` 目录，且将启动和停止脚本重新命名为 `config.sh` 和 `start.sh` 和 `stop.sh`，以便更清晰的管理和组织。

- **代理配置移除**：移除了所有默认的代理配置。如果需要使用代理，用户需要手动在 Linux 环境中通过 `export` 命令进行配置。

---

## ⭐ 特性

- **UI 问题修复**：修复了空 URL 导致 UI 无法加载的错误，确保 UI 正常工作。
- **简化代理配置**：移除了默认的代理设置，用户可以自由配置代理。
- **脚本重组与改名**：原有的 `start.sh`、`shutdown.sh` 和 `restart.sh` 被移至 `script/` 目录，并且现有的配置脚本改为`config.sh`，启动脚本改名为 `start.sh`，停止脚本为 `stop.sh`。
- **环境变量清空**：项目初始化时不再预设任何环境变量，允许用户完全自定义配置。

---

## 🚀 安装

1. 克隆仓库：

   ```bash
   git clone https://github.com/pldz1/clash-linux.git
   cd clash-linux
   ```

2. 配置环境变量（如有需要）：
   用户可以修改 `env` 文件中的环境变量, 默认不修改则只会启动 UI 项目。

3. 赋予可执行权限：

   ```
   sudo chmod +x -R ./scripts
   ```

4. 运行应用程序：
   - 配置服务: 如果 env 的连接是空的话，会提示错误 但是不影响后续 `start.sh` 执行
     ```bash
     ./script/config.sh
     ```
   - 启动服务：
     ```bash
     ./script/start.sh
     ```
   - 停止服务：
     ```bash
     ./script/stop.sh
     ```

---

## 🛜 代理配置

由于本项目已移除默认的代理配置，用户需要手动配置代理。如果需要使用代理，可以通过以下命令进行设置：

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export no_proxy=127.0.0.1,localhost
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export NO_PROXY=127.0.0.1,localhost
```

去掉代理的指令

```bash
	unset http_proxy
	unset https_proxy
	unset no_proxy
  	unset HTTP_PROXY
	unset HTTPS_PROXY
	unset NO_PROXY
```

---

## 😄 贡献

欢迎 Fork 本仓库并根据需要进行修改。如果您遇到任何问题或发现 Bug，请提交 Issue 或 Pull Request。

---

## 📖 许可证

此项目采用 MIT 许可证 - 详情请见 [LICENSE](LICENSE) 文件。

---
