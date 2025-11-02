# =========================
# Stage 1 — Base environment
# =========================
FROM python:3.11-slim AS base

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 安装 uv（Python 包管理器）
RUN pip install --no-cache-dir uv

# =========================
# 安装依赖（指定在 /python 文件夹）
# =========================
COPY python/pyproject.toml ./pyproject.toml

RUN uv sync || (pip install -r python/requirements.txt || true)

# =========================
# 拷贝所有源代码
# =========================
COPY . .

# 切换到后端目录（包含 main.py 的那层）
WORKDIR /app/python

# =========================
# 环境变量
# =========================
ENV API_HOST=0.0.0.0
ENV API_PORT=${PORT:-8000}

# =========================
# 启动服务
# =========================
CMD ["uv", "run", "python", "-m", "valuecell.server.main"]
