# 网络与系统修复工具箱 Network Repair Toolbox

> Windows 网络与系统故障诊断修复工具集 · 纯批处理实现 · 零外部依赖

> ⚠️ **AI 使用说明**：本作品使用 AI 辅助生成（生成时间：2026-09-16）。仅供学习与参考使用，发布、引用或投入使用前请人工核实关键信息。

---

## 这是什么

一个单文件 Windows 批处理（`.bat`）工具箱，把常见的网络排障与系统修复操作收进一个中文菜单里：断网重连、DNS/协议栈重置、代理与 hosts 排查、防火墙与 MTU 检查等，全部基于系统自带命令（`netsh` / `ipconfig` / `reg` / `PowerShell`），**不需要安装任何额外软件**。

v0.6.0 新增「**网络问题扫描与修复**」：一次扫描 13 项网络健康指标，自动列出问题清单，可一键修复或查看手动处理指引。

---

## 功能一览

### 🩺 网络问题扫描与修复（v0.6.0 新增）

菜单路径：`网络修复工具 → [25] 网络问题扫描与修复`

**扫描 13 项**：网络适配器状态、IPv4 地址（含 APIPA 检测）、默认网关连通性、外网连通性、DNS 解析、DNS 服务器配置、系统代理设置、hosts 文件劫持、DHCP 客户端服务、DNS Client 服务、Windows 防火墙状态、HTTPS 443 端口连通性、MTU 大小。

**扫描完成后**：
- 列出全部问题清单，**能自动修的标记修复动作，不能自动修的直接给出具体手动指引**（如"检查网线 / Wi-Fi 开关 / 飞行模式 / 设备管理器网卡驱动"）
- 可选择 **一键修复全部** / **仅查看** / **返回**

**自动修复动作**：

| 问题 | 修复动作 |
|------|---------|
| IPv4 获取失败 / APIPA 地址 | 释放并重新获取 IP |
| 网关不通 / 外网不通 / 443 不通 | 重置 Winsock + TCP/IP + WinHTTP 代理 |
| DNS 解析失败 / 未配置 DNS | 刷新 DNS 缓存 + 设置公共 DNS（223.5.5.5 / 119.29.29.29）|
| 系统代理开启 | 重置系统代理与 PAC |
| DHCP / DNS Client 服务未运行 | 设为自动启动并拉起服务 |
| 防火墙未启用 | 启用 Windows 防火墙 |
| hosts 疑似劫持 | 备份后清理劫持条目（保留 `hosts.bak_*` 备份）|
| MTU 过大 | 自动调整为 1400（失败时输出手动命令）|

### 🔧 网络修复工具（25 项）

`01` 创建系统还原点 · `02` 备份网络注册表 · `03` 恢复网络注册表 · `04` 快速断网重连 · `05` 忘记当前 Wi-Fi · `06` 释放并更新 IP · `07` 刷新 DNS 缓存 · `08` 重置 Winsock 与 IP 协议栈 · `09` 清除 SSL 证书缓存 · `10` 清除 ARP 缓存 · `11` TCP 连接修复 · `12` 修改 MAC 地址 · `13` 恢复原始 MAC · `14` 360 断网急救箱 · `15` 360 LSP 修复工具 · `16` 一键全面修复 · `17` 网络检测工具 · `18` 高级网络工具 · `19` 打开 Hosts 文件 · `20` 重启电脑 · `21` 防火墙状态查看 · `22` 重置代理服务器设置 · `23` 重置网络共享设置 · `24` 设置 MTU 值 · `25` 网络问题扫描与修复

- **网络检测工具**：IP 详情 / 网关连通 / DNS 解析（含指定 DNS 服务器） / 端口连通 / 网站连通 / 一键全面检测
- **高级网络工具**：强制重置无线网卡 / 删除虚拟适配器 / 深度清理 Wi-Fi 配置
- **防火墙状态查看**：深度诊断（生成报告）/ 检查出站规则 / 检查入站规则

### 🖥️ 系统修复工具

重启资源管理器 · 管理员 CMD · 安全软件下载 · Windows 更新管理（暂停 1-35 天 / 恢复 / 彻底禁用 / 恢复自动更新）

### 🧰 常用工具

关机 / 重启 / 注销 / 休眠 / 关闭指定进程 / 程序列表 / 任务管理器 / CMD / 注册表编辑器 / 启动程序 / 批量修改文件后缀（移除 / 添加 / 替换）/ 桌面快捷方式启动 / ZIP 解压（三种模式）/ 强制开启英文输入法 / 定时关机（`1h2m3s` 格式）/ 取消关机

### ⚡ 特殊工具

以管理员权限启动任意程序

---

## 使用方法

1. **下载**：获取 `NetworkRepairToolbox.bat`（或 `git clone` 本仓库）
2. **运行**：双击 `NetworkRepairToolbox.bat`
3. **建议选管理员模式**：启动时选 `[1] 管理员模式`，否则大量修复功能无法执行（工具会自动提示并请求 UAC 提权）
4. 按菜单数字选择功能即可

**环境要求**：Windows 10 / 11（中文系统）。编码为 GBK（936），无需配置。

---

## 注意事项

- ⚠️ **修复类操作会修改系统网络配置**：重置 Winsock / TCP/IP / 代理等操作建议先创建还原点（工具箱 `网络修复工具 → [01]`）
- ⚠️ **部分修复需重启才完全生效**（Winsock / TCP/IP / DNS 重置类）
- ⚠️ **hosts 清理会移除匹配的疑似劫持条目**：如果你曾手动用 hosts 屏蔽广告域名，请选择不修复；清理前会自动生成 `hosts.bak_<时间戳>` 备份
- ⚠️ **Internet 连接共享 / 代理软件用户注意**：重置代理和网络共享设置会清除相关配置
- 🔒 工具本身**不联网上传任何数据**，所有操作均在本机执行；涉及第三方软件的入口仅给出官方链接，不附带任何第三方二进制分发

---

## 项目结构

```
Network-Repair-Toolbox/
├── NetworkRepairToolbox.bat   # 主程序（单文件，GBK 编码）
├── README.md                  # 本文档
└── LICENSE                    # MIT
```

---

## 许可证

代码以 [MIT License](./LICENSE) 发布。

---

## English

**Network Repair Toolbox** — a single-file Windows batch toolbox for network & system troubleshooting. No external dependencies — everything runs on built-in Windows commands (`netsh` / `ipconfig` / `reg` / PowerShell).

**Highlights (v0.6.0)**: a new **Network Problem Scan & Repair** module that scans 13 health checks (adapter, IPv4/APIPA, gateway, internet, DNS resolution, DNS config, proxy, hosts hijacking, DHCP service, DNS Client service, firewall, HTTPS port 443, MTU), lists all findings, and offers one-click repair — items that can't be automated come with concrete manual instructions.

Other modules: 25 network repair actions (Winsock/TCP-IP reset, DNS flush, proxy/hosts reset, MAC address, MTU, Wi-Fi profile cleanup, firewall diagnosis...), system repair (Explorer restart, Windows Update control), and common utilities (batch file-extension rename, ZIP extract, timed shutdown...).

**Requirements**: Windows 10/11 (Chinese system, GBK/936 encoding). Run as Administrator for repair functions.

**Note**: Repair operations modify system network configuration. Create a restore point first (menu `[01]`) if unsure. Some fixes require a reboot to take full effect.
