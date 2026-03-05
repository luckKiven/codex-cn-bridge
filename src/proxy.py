"""
Codex CN Bridge - OpenAI Responses API → Chat Completions 协议转换代理
支持阿里云通义千问、Kimi、智谱等国内模型

用法：python proxy.py
端口：http://localhost:3000
"""

from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
import httpx
import yaml
import os
import json
import time
from typing import Optional, Dict, Any
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

app = FastAPI(title="Codex CN Bridge", version="1.0.0")

# 允许 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 加载模型配置
def load_models_config() -> Dict[str, Any]:
    """加载 models.yaml 配置"""
    config_path = os.path.join(os.path.dirname(__file__), "models.yaml")
    if not os.path.exists(config_path):
        return {}
    
    with open(config_path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

MODELS_CONFIG = load_models_config()

def get_model_info(model_name: str) -> Optional[Dict[str, Any]]:
    """根据模型名称获取配置信息"""
    models = MODELS_CONFIG.get("models", [])
    for model in models:
        if model.get("name") == model_name:
            return model
    return None

def get_api_key(model_name: str) -> str:
    """获取模型对应的 API Key"""
    model_info = get_model_info(model_name)
    if model_info:
        env_key = model_info.get("env_key", "QWEN_API_KEY")
    else:
        env_key = "QWEN_API_KEY"
    
    api_key = os.getenv(env_key)
    if not api_key:
        raise HTTPException(status_code=500, detail=f"API Key not found: {env_key}")
    
    return api_key

async def generate_sse_stream(model: str, user_input: str, model_info: dict, api_key: str, api_base: str):
    """生成 SSE 流式响应（兼容 Codex Responses API）"""
    try:
        # 构建流式 Chat Completions 请求
        chat_payload = {
            "model": model_info.get("model_id", model) if model_info else model,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": user_input}
                    ]
                }
            ],
            "temperature": 0.7,
            "max_tokens": 2048,
            "stream": True
        }
        
        response_id = f"resp_{int(time.time())}"
        item_id = f"item_{int(time.time())}"
        
        async with httpx.AsyncClient(timeout=120.0) as client:
            async with client.stream(
                "POST",
                api_base,
                json=chat_payload,
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json"
                }
            ) as resp:
                if resp.status_code != 200:
                    error_text = await resp.aread()
                    raise Exception(f"Upstream error: {error_text.decode()}")
                
                # 1. response.created
                yield f"data: {json.dumps({'type': 'response.created', 'response': {'id': response_id, 'status': 'in_progress', 'model': model}})}\n\n"
                
                # 2. response.output_item.added
                yield f"data: {json.dumps({'type': 'response.output_item.added', 'item': {'id': item_id, 'type': 'message', 'role': 'assistant', 'status': 'in_progress'}, 'response_id': response_id, 'output_index': 0})}\n\n"
                
                # 3. response.content_part.added
                yield f"data: {json.dumps({'type': 'response.content_part.added', 'part': {'type': 'output_text', 'text': ''}, 'item_id': item_id, 'response_id': response_id, 'output_index': 0, 'content_index': 0})}\n\n"
                
                full_content = ""
                
                # 4. response.output_text.delta (多次)
                async for line in resp.aiter_lines():
                    if line.startswith("data: "):
                        data = line[6:]
                        if data.strip() == "[DONE]":
                            break
                        
                        try:
                            chunk = json.loads(data)
                            delta = chunk.get("choices", [{}])[0].get("delta", {})
                            content = delta.get("content", "")
                            
                            if content:
                                full_content += content
                                yield f"data: {json.dumps({'type': 'response.output_text.delta', 'delta': content, 'item_id': item_id, 'response_id': response_id, 'output_index': 0, 'content_index': 0})}\n\n"
                        except json.JSONDecodeError:
                            continue
                
                # 5. response.content_part.done
                yield f"data: {json.dumps({'type': 'response.content_part.done', 'part': {'type': 'output_text', 'text': full_content}, 'item_id': item_id, 'response_id': response_id, 'output_index': 0, 'content_index': 0})}\n\n"
                
                # 6. response.output_item.done
                yield f"data: {json.dumps({'type': 'response.output_item.done', 'item': {'id': item_id, 'type': 'message', 'role': 'assistant', 'status': 'completed', 'content': [{'type': 'output_text', 'text': full_content}]}, 'response_id': response_id, 'output_index': 0})}\n\n"
                
                # 7. response.completed
                yield f"data: {json.dumps({'type': 'response.completed', 'response': {'id': response_id, 'status': 'completed', 'output': [{'type': 'message', 'role': 'assistant', 'content': [{'type': 'output_text', 'text': full_content}]}], 'model': model}})}\n\n"
                
    except Exception as e:
        yield f"data: {json.dumps({'type': 'error', 'error': str(e)})}\n\n"

@app.post("/responses")
@app.post("/v1/responses")
async def responses_proxy(
    payload: Dict[str, Any],
    authorization: Optional[str] = Header(None)
):
    """
    OpenAI Responses API 端点
    转换为 Chat Completions API 调用国内模型
    支持 /responses 和 /v1/responses 两个路径
    支持流式和非流式响应
    """
    try:
        # 1. 解析 Responses API 请求
        model = payload.get("model", "qwen3.5-plus")
        stream = payload.get("stream", True)  # Codex 默认使用流式
        user_input = payload.get("input")
        
        # 处理 Codex 的 input 格式（可能是字符串或数组）
        if isinstance(user_input, list):
            user_input = " ".join([item.get("text", str(item)) if isinstance(item, dict) else str(item) for item in user_input])
        
        if not user_input:
            raise HTTPException(status_code=400, detail="Missing 'input' field")
        
        # 2. 获取模型配置
        model_info = get_model_info(model)
        api_base = model_info.get("api_base") if model_info else None
        api_key = get_api_key(model)
        
        if not api_base:
            raise HTTPException(status_code=400, detail=f"Model not configured: {model}")
        
        # 3. 流式响应
        if stream:
            return StreamingResponse(
                generate_sse_stream(model, user_input, model_info, api_key, api_base),
                media_type="text/event-stream",
                headers={
                    "Cache-Control": "no-cache",
                    "Connection": "keep-alive",
                    "X-Accel-Buffering": "no"
                }
            )
        
        # 4. 非流式响应（备用）
        chat_payload = {
            "model": model_info.get("model_id", model) if model_info else model,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": user_input}
                    ]
                }
            ],
            "temperature": 0.7,
            "max_tokens": 2048,
            "stream": False
        }
        
        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(
                api_base,
                json=chat_payload,
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json"
                }
            )
            
            if resp.status_code != 200:
                raise HTTPException(
                    status_code=resp.status_code,
                    detail=f"Upstream error: {resp.text}"
                )
            
            chat_resp = resp.json()
        
        choice = chat_resp.get("choices", [{}])[0]
        message = choice.get("message", {})
        output = message.get("content", "")
        
        return {
            "id": f"resp_{chat_resp.get('id', 'unknown')}",
            "object": "response",
            "created_at": chat_resp.get('created', 1709625600),
            "status": "completed",
            "model": model,
            "output": output,
            "usage": chat_resp.get("usage", {})
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/v1/chat/completions")
async def chat_completions_proxy(
    payload: Dict[str, Any],
    authorization: Optional[str] = Header(None)
):
    """
    Chat Completions API 端点（兼容模式）
    直接转发到国内模型 API
    """
    try:
        model = payload.get("model", "qwen3.5-plus")
        model_info = get_model_info(model)
        api_base = model_info.get("api_base") if model_info else None
        api_key = get_api_key(model)
        
        if not api_base:
            raise HTTPException(status_code=400, detail=f"Model not configured: {model}")
        
        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(
                api_base,
                json=payload,
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json"
                }
            )
            
            if resp.status_code != 200:
                raise HTTPException(
                    status_code=resp.status_code,
                    detail=f"Upstream error: {resp.text}"
                )
            
            return resp.json()
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/v1/models")
async def list_models():
    """返回可用的模型列表"""
    models = MODELS_CONFIG.get("models", [])
    return {
        "object": "list",
        "data": [
            {
                "id": model.get("name"),
                "object": "model",
                "created": 1709625600,
                "owned_by": "codex-cn-bridge"
            }
            for model in models
        ]
    }

@app.get("/health")
async def health_check():
    """健康检查"""
    return {
        "status": "healthy",
        "port": 3000,
        "models_loaded": len(MODELS_CONFIG.get("models", [])),
        "version": "1.0.0"
    }

if __name__ == "__main__":
    import uvicorn
    
    print("""
╔══════════════════════════════════════════════════════════╗
║              Codex CN Bridge Server v1.0.0               ║
║     OpenAI Responses API → Chat Completions Proxy        ║
╚══════════════════════════════════════════════════════════╝

    服务启动中...
    监听地址：http://localhost:3000
    可用端点:
       - POST /v1/responses (Responses API)
       - POST /responses    (兼容 Codex)
       - POST /v1/chat/completions (Chat API)
       - GET  /v1/models
       - GET  /health
    
    按 Ctrl+C 停止服务
    """)
    
    uvicorn.run(app, host="0.0.0.0", port=3000)
