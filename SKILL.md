# Codex CN Bridge Skill

**让 OpenAI Codex CLI 使用国内 AI 模型（阿里云 Qwen、Kimi、智谱 GLM 等，目前默认支持百炼 coding plan）**

---

## 🎯 功能

- ✅ **协议转换** - OpenAI Responses API → 国内模型 Chat API
- ✅ **多模型支持** - Qwen3.5-Plus、Qwen-Coder-Plus、Qwen3-Max、Kimi-K2.5、GLM-5
- ✅ **一键启动** - 自动配置 Codex，无需手动设置
- ✅ **双配置模式** - 支持 `.env` 文件 或 环境变量

---

## 📦 安装

### 方式 1：ClawHub 安装（推荐）

```bash
openclaw skills install codex-cn-bridge
```

### 方式 2：GitHub 克隆

```bash
git clone https://github.com/luckKiven/codex-cn-bridge.git
cp -r codex-cn-bridge ~/.openclaw/workspace/skills/
```

### 方式 3：GitHub 下载 ZIP

1. 下载：https://github.com/luckKiven/codex-cn-bridge/archive/refs/heads/main.zip
2. 解压到 `~/.openclaw/workspace/skills/`

---

## ⚙️ 配置（二选一）

### ⚠️ 安全提醒

**`.env` 文件包含敏感 API Key，请勿上传到 GitHub 或公开分享！**

Skill 已提供 `.env.example` 模板，复制后修改：

```bash
cp ~/.codex/cn-bridge.env.example ~/.codex/cn-bridge.env
# 然后编辑 .env 文件填入真实 API Key
```

### 方式 1：`.env` 文件（推荐）

编辑 `~/.codex/cn-bridge.env`：

```bash
# 阿里云通义千问（推荐）
QWEN_API_KEY=sk-your-alibaba-cloud-key

# 月之暗面 Kimi（可选）
KIMI_API_KEY=sk-your-moonshot-key

# 智谱 GLM（可选）
ZHIPU_API_KEY=sk-your-zhipu-key
```

### 方式 2：环境变量

```bash
# PowerShell
$env:QWEN_API_KEY="sk-your-key"

# CMD
set QWEN_API_KEY=sk-your-key

# 永久设置（推荐）
[System.Environment]::SetEnvironmentVariable("QWEN_API_KEY", "sk-your-key", "User")
```

---

## 🚀 使用

### 启动服务

```bash
/codex-cn-bridge start
```

### 测试连接

```bash
/codex-cn-bridge test
```

### 执行 Codex 命令

```bash
/codex-cn-bridge exec "帮我写个快速排序"
```

### 进入交互模式

```bash
/codex-cn-bridge interactive
```

### 查看状态

```bash
/codex-cn-bridge status
```

### 停止服务

```bash
/codex-cn-bridge stop
```

---

## 🛡️ 守护进程监控（推荐）

**自动监控 qwen-proxy 服务，异常时自动重启并告警**

### 启动守护进程

```bash
/codex-cn-bridge watchdog
```

### 查看守护进程状态

```bash
/codex-cn-bridge watchdog-status
```

### 查看监控日志

```bash
/codex-cn-bridge watchdog-logs
```

### 实时跟踪日志

```bash
/codex-cn-bridge watchdog-logs -Follow
```

### 停止守护进程

```bash
/codex-cn-bridge watchdog-stop
```

### 守护进程功能

- ✅ **自动监控** - 每 30 秒检查服务状态
- ✅ **自动重启** - 服务停止时自动重启
- ✅ **健康检查** - 每 5 分钟执行 HTTP 健康检查
- ✅ **异常告警** - 服务异常时主动汇报
- ✅ **日志记录** - 完整记录运行日志

---

## 📊 可用模型

| 模型名称 | 提供商 | 适用场景 |
|---------|--------|---------|
| `qwen3.5-plus` | 阿里云 | 通用任务（推荐） |
| `qwen-coder-plus` | 阿里云 | 编程专用 |
| `qwen3-max` | 阿里云 | 复杂任务（最强） |
| `kimi-k2.5` | 月之暗面 | 长文本处理 |
| `glm-5` | 智谱 | 通用任务 |

---

## 🔧 切换模型

```bash
# 使用编程专用模型
codex exec -c model="qwen-coder-plus" -c model_provider="cn-bridge" "写个函数"

# 使用最强模型
codex exec -c model="qwen3-max" -c model_provider="cn-bridge" "复杂任务"
```

---

## ⚠️ 注意事项

1. **服务需保持运行** - 使用 Codex 前确保代理服务已启动
2. **API Key 必备** - 至少配置一个模型的 API Key
3. **端口占用** - 默认使用 3000 端口，如被占用请修改配置

---

## 📁 文件结构

```
~/.codex/
├── cn-bridge.env          # API Key 配置
├── config.toml            # Codex 配置（自动创建）
└── cn-bridge/             # 代理服务目录
    ├── proxy.py           # 协议转换服务
    ├── models.yaml        # 模型配置
    └── start.bat          # 启动脚本
```

---

## 🆘 常见问题

### Q: 启动失败，端口被占用
**A:** 运行 `/codex-cn-bridge stop` 停止旧进程，或修改配置中的端口

### Q: Codex 切换模型卡住
**A:** 
1. 检查服务状态：`/codex-cn-bridge status`
2. 检查 API Key 是否正确
3. 查看日志：`~/.codex/cn-bridge/logs/`

### Q: 添加新模型
**A:** 编辑 `~/.codex/cn-bridge/models.yaml`，添加新模型配置

---

## 💡 技术原理

```
Codex CLI (Responses API)
        ↓
   [协议转换层]
   OpenAI Responses → Chat Completions
        ↓
   国内模型 API
   (阿里云 / Kimi / 智谱)
        ↓
   [响应转换层]
   Chat Completions → Responses
        ↓
Codex CLI 收到响应
```

---

**版本：** 1.0.0  
**作者：** jixiang  
**许可：** MIT（完全开源，免费使用）  
**GitHub：** https://github.com/luckKiven/codex-cn-bridge
