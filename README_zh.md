# OpenCode 彻底卸载工具

[English README](README.md)

---

本仓库提供了用于从系统中彻底、干净地卸载 **OpenCode** 的脚本。

### ❓ 适用场景
当 OpenCode 处于异常状态时，请使用此工具清理并重置环境：
* **无法启动**：OpenCode 无法打开、启动时闪退或卡在无限加载界面。
* **数据异常 / 获取异常**：程序抛出数据库错误、文件系统异常或配置文件读取冲突。
* **干净重装**：您希望执行一次完全干净的重新安装，不留任何残留缓存、历史配置或本地工作数据库。

> [!WARNING]
> **此操作不可逆，将永久删除数据！**
> 脚本将永久清除以下内容：
> * 所有 OpenCode 应用程序、二进制文件和环境变量。
> * 本地项目配置、数据库、存储文件和工作目录记录。
> * 会话历史记录、日志以及 Agent 的记忆缓存。
>
> 如果有重要数据，请在运行脚本前尝试备份 `~/.config/opencode` 或 `~/.local/share/opencode`（Windows 下为 `%APPDATA%\opencode` 与 `%LOCALAPPDATA%\opencode`）目录。

### 🚀 使用方法

#### macOS / Linux
1. 打开终端（Terminal）。
2. 进入脚本所在目录并执行：
   ```bash
   bash uninstall-opencode.sh
   ```
3. 根据提示输入 `YES` 确认彻底删除。
4. 重启终端以更新环境变量。

#### Windows
1. 打开文件资源管理器找到 `uninstall-opencode.bat`。
2. **右键点击** `uninstall-opencode.bat`，选择 **“以管理员身份运行”**（清理系统路径及 HKLM 注册表必须）。
3. 根据提示输入 `YES` 确认彻底删除。
4. 重启命令行窗口（CMD/PowerShell）或注销账户以更新系统 `PATH` 变量。
