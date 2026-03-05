# Codex CN Bridge

**让 OpenAI Codex CLI 使用国内 AI 模型（阿里云 Qwen、Kimi、智谱 GLM 等）**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![ClawHub](https://img.shields.io/badge/ClawHub-codex--cn--bridge-blue)](https://clawhub.ai)

---

## 🎯 功能

- ✅ **协议转换** - OpenAI Responses API → 国内模型 Chat API
- ✅ **多模型支持** - Qwen3.5-Plus、Qwen-Coder-Plus、Qwen3-Max、Kimi-K2.5、GLM-5
- ✅ **一键启动** - 自动配置 Codex，无需手动设置
- ✅ **双配置模式** - 支持 `.env` 文件 或 环境变量
- ✅ **流式响应** - 完整支持 SSE 流式输出

---

## 📦 安装

### 方式 1：ClawHub（推荐）

```bash
# 安装 skill
openclaw skills install codex-cn-bridge

# 下载完整代码
/codex-cn-bridge install
```

### 方式 2：GitHub

```bash
# 克隆仓库
git clone https://github.com/luckKiven/codex-cn-bridge.git

# 复制到 skills 目录
cp -r codex-cn-bridge ~/.openclaw/workspace/skills/
```

---

## ⚙️ 配置

### 安全提醒

⚠️ **`.env` 文件包含敏感 API Key，请勿上传到 GitHub 或公开分享！**

### 步骤

1. **复制模板**
   ```bash
   cp .env.example .env
   ```

2. **编辑 `.env` 填入 API Key**
   ```bash
   # 阿里云通义千问（推荐）
   QWEN_API_KEY=sk-your-alibaba-cloud-key
   
   # 月之暗面 Kimi（可选）
   KIMI_API_KEY=sk-your-moonshot-key
   
   # 智谱 GLM（可选）
   ZHIPU_API_KEY=sk-your-zhipu-key
   ```

---

## 🚀 使用

```bash
# 启动服务
/codex-cn-bridge start

# 测试连接
/codex-cn-bridge test

# 执行 Codex 命令
/codex-cn-bridge exec "帮我写个快速排序"

# 查看状态
/codex-cn-bridge status

# 停止服务
/codex-cn-bridge stop
```

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

## 📁 项目结构

```
codex-cn-bridge/
├── SKILL.md              # OpenClaw 技能文档
├── skill.json            # 技能元数据
├── src/
│   └── proxy.py          # 协议转换服务
├── scripts/
│   ├── start-proxy.ps1   # 启动脚本
│   ├── stop-proxy.ps1    # 停止脚本
│   ├── check-proxy.ps1   # 状态检查
│   ├── test-connection.ps1 # 连接测试
│   └── install-package.ps1 # 安装脚本
├── config/
│   └── models.yaml       # 模型配置
├── .env.example          # 环境变量模板
└── .gitignore            # Git 忽略文件
```

---

## 🆘 常见问题

### Q: 启动失败，端口被占用
**A:** 运行 `/codex-cn-bridge stop` 停止旧进程

### Q: Codex 切换模型卡住
**A:** 
1. 检查服务状态：`/codex-cn-bridge status`
2. 检查 API Key 是否正确
3. 查看日志

### Q: 添加新模型
**A:** 编辑 `config/models.yaml`，添加新模型配置

---

## 💰 定价

- **免费版**：开源基础功能
- **专业版**：¥199（多模型负载均衡 + 日志审计 + 技术支持）
- **企业版**：¥999（私有部署 + 定制开发 + 培训）

---

## 📧 联系

- **GitHub**: https://github.com/luckKiven/codex-cn-bridge
- **ClawHub**: https://clawhub.ai

---

## 📄 许可

MIT License

---

**Made with ❤️ by jixiang**
