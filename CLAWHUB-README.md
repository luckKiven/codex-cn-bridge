# Codex CN Bridge - ClawHub 发布说明

## 📦 发布包

### 1. ClawHub 版本（只包含 SKILL.md）
**文件：** `codex-cn-bridge-clawhub.zip`  
**大小：** 2 KB  
**内容：** 仅 `SKILL.md`

**上传到：** https://clawhub.ai/upload

---

### 2. 完整代码包（包含所有文件）
**文件：** `codex-cn-bridge.zip`  
**大小：** 15 KB  
**内容：** 完整 skill 代码（scripts、src、config 等）

**上传到 GitHub Releases：** https://github.com/luckKiven/codex-cn-bridge/releases

---

## 📝 ClawHub 表单填写

### 基本信息
```
名称：codex-cn-bridge
版本：1.0.0
描述：让 OpenAI Codex CLI 使用国内 AI 模型（阿里云 Qwen、Kimi、智谱 GLM 等）
标签：codex, qwen, 国内模型，协议转换，AI 编程，百炼
```

### 分类
```
主分类：Developer Tools
子分类：AI & Machine Learning
```

### 仓库链接
```
https://github.com/luckKiven/codex-cn-bridge
```

### 定价
```
- 免费版：✅ 是
- 付费版：✅ 是（专业版 ¥199，企业版 ¥999）
```

---

## 📄 README 内容（复制粘贴）

```markdown
# Codex CN Bridge

让 OpenAI Codex CLI 使用国内 AI 模型（阿里云 Qwen、Kimi、智谱 GLM 等）

## 功能

- ✅ 协议转换：OpenAI Responses API → Chat Completions
- ✅ 多模型支持：Qwen3.5-Plus、Qwen-Coder-Plus、Qwen3-Max、Kimi-K2.5、GLM-5
- ✅ 一键启动：自动配置 Codex
- ✅ 双配置模式：.env 文件 / 环境变量

## 安装

```bash
# 安装 skill
openclaw skills install codex-cn-bridge

# 下载完整代码
/codex-cn-bridge install
```

## 配置

```bash
# 复制模板
cp ~/.codex/cn-bridge.env.example ~/.codex/cn-bridge.env

# 编辑 .env 填入 API Key
```

## 使用

```bash
/codex-cn-bridge start    # 启动服务
/codex-cn-bridge test     # 测试连接
/codex-cn-bridge exec "问题"  # 执行命令
```

## GitHub

https://github.com/luckKiven/codex-cn-bridge

## 定价

- 免费版：开源基础功能
- 专业版：¥199（多模型负载均衡 + 日志审计）
- 企业版：¥999（私有部署 + 定制开发）

## 许可

MIT License
```

---

## ✅ 发布检查清单

- [ ] 上传 `codex-cn-bridge-clawhub.zip` 到 ClawHub
- [ ] 填写表单信息
- [ ] 粘贴 README 内容
- [ ] 设置定价（免费 + 付费）
- [ ] 提交审核
- [ ] 上传完整代码到 GitHub Releases
- [ ] 更新 GitHub README

---

**祝发布顺利！** 🚀
