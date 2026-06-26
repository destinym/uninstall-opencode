# OpenCode Thorough Uninstall Utility

[中文说明文档](README_zh.md)

---

This repository provides scripts to completely and cleanly uninstall **OpenCode** from your system. 

### ❓ When to Use This Utility
Use these scripts if OpenCode is in an abnormal state, for example:
* **Cannot Start**: OpenCode fails to launch, crashes immediately on startup, or is stuck in an infinite loading loop.
* **Corrupted State / Database Errors**: The application throws database exceptions, file-system errors, or has issues reading configuration files.
* **Troubled Reinstallation**: You want to perform a completely clean reinstall of OpenCode without residual cache, settings, or workspace databases.

> [!WARNING]
> **This action is destructive and irreversible!** 
> It will permanently delete:
> * All OpenCode applications, binaries, and environment links.
> * Local project configurations, databases, storage files, and workspace records.
> * Session histories, logs, and agent memory cache.
>
> If you have critical data, please try to back up your `~/.config/opencode` or `~/.local/share/opencode` folders before running this script.

### 🚀 How to Run

#### macOS / Linux
1. Open your terminal.
2. Navigate to the folder containing the script and run:
   ```bash
   bash uninstall-opencode.sh
   ```
3. Type `YES` when prompted to confirm the deletion.
4. Restart your terminal to refresh environmental variables.

#### Windows
1. Open File Explorer and find `uninstall-opencode.bat`.
2. **Right-click** on `uninstall-opencode.bat` and select **"Run as administrator"**. (Required to clean up system directories and registry keys).
3. Type `YES` when prompted to confirm the deletion.
4. Restart your Command Prompt/PowerShell window or log out to refresh your `PATH` variable.
