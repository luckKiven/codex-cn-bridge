# Codex CN Bridge - ClawHub 发布清单

## ✅ 已准备完成

### 文件检查
- [x] `SKILL.md` - 用户文档（含安全提醒）
- [x] `skill.json` - 技能元数据
- [x] `scripts/` - PowerShell 脚本（4 个）
- [x] `src/proxy.py` - 协议转换服务
- [x] `config/models.yaml` - 模型配置
- [x] `.env.example` - 环境变量模板（脱敏）
- [x] `.gitignore` - Git 忽略文件
- [x] `README-release.md` - 发布说明

### 安全检查
- [x] 无硬编码 API Key
- [x] `.env` 未包含在发布包中
- [x] 所有 Key 通过环境变量引用

### 发布包
- **位置**: `C:\Users\14015\.openclaw\workspace\skills\codex-cn-bridge.zip`
- **大小**: 11.3 KB
- **文件数**: 10 个

---

## 📤 上传步骤

### 1. 访问 ClawHub
打开：https://clawhub.ai/upload

### 2. 填写信息

**基本信息**
```
名称：codex-cn-bridge
版本：1.0.0
描述：让 OpenAI Codex CLI 使用国内 AI 模型（协议转换）
标签：codex, qwen, 国内模型，协议转换，AI 编程
```

**分类**
```
主分类：Developer Tools
子分类：AI & Machine Learning
```

**定价**
```
- 免费版：是（开源）
- 付费版：是（专业版 ¥199，企业版 ¥999）
```

### 3. 上传文件
上传 `codex-cn-bridge.zip`

### 4. 填写 README
使用 `README-release.md` 内容

### 5. 提交审核

---

## 📝 ClawHub 表单字段参考

```markdown
## Description
让 OpenAI Codex CLI 使用国内 AI 模型（阿里云 Qwen、Kimi、智谱 GLM 等）
通过协议转换技术，将 OpenAI Responses API 转换为国内模型的 Chat API

## Features
- 协议转换（Responses API → Chat Completions）
- 支持 5 个国内主流模型
- 一键启动/停止/测试
- 流式响应支持（SSE）
- 双配置模式（.env / 环境变量）

## Installation
1. 下载并解压到 OpenClaw skills 目录
2. 复制 .env.example 为 .env 并配置 API Key
3. 运行 /codex-cn-bridge start

## Usage
/codex-cn-bridge start      # 启动服务
/codex-cn-bridge test       # 测试连接
/codex-cn-bridge exec "问题" # 执行 Codex 命令

## Security
- API Key 通过环境变量管理
- .env 文件已加入 .gitignore
- 无硬编码敏感信息
```

---

## 🎯 后续步骤

1. **提交审核** - 等待 ClawHub 审核（通常 1-2 天）
2. **推广** - B 站、知乎、掘金发教程
3. **变现** - 面包多上架企业版
4. **迭代** - 根据用户反馈更新

---

**祝发布顺利！** 🚀
