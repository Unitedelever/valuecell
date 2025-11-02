# ---- base image ----
FROM python:3.11-slim AS base

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# ---- install uv ----
RUN pip install --no-cache-dir uv

# ---- copy and install dependencies ----
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# ---- copy source code ----
COPY . .

# ---- 设置工作目录到 Python 后端 ----
WORKDIR /app/python

# ---- 环境变量 ----
# Render 会自动注入 OPENAI_API_KEY、OPENROUTER_API_KEY、MODEL_PROVIDER、API_HOST 等
# 我们手动保证默认绑定端口给 Render 探测
ENV API_HOST=0.0.0.0
ENV API_PORT=${PORT:-8000}

# ---- 启动服务 ----
CMD ["uv", "run", "python", "-m", "valuecell.server.main"]
