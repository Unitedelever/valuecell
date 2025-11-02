# =========================
# Stage 1 — Base environment
# =========================
FROM python:3.11-slim AS base

# 设置工作目录
WORKDIR /app

# 安装系统依赖（curl 用于健康检查或后续扩展）
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# =========================
# Stage 2 — Install uv
# =========================
# uv 是一个现代 Python 包管理器（项目中使用）
RUN pip install --no-cache-dir uv

# =========================
# Stage 3 — 安装依赖
# =========================
# 复制 pyproject.toml（这里不包含 uv.lock，因为你没有这个文件）
COPY pyproject.toml ./

# 使用 uv 同步依赖，如果失败则尝试用 pip 安装（兼容性更强）
RUN uv sync || (pip install -r requirements.txt || true)

# =========================
# Stage 4 — 拷贝源代码
# =========================
COPY . .

# 切换到 Python 后端目录（ValueCell 的主程序）
WORKDIR /app/python

# =========================
# Stage 5 — 环境变量
# =========================
# Render 会自动注入 OPENAI_API_KEY / OPENROUTER_API_KEY / MODEL_PROVIDER 等变量
# 我们只手动设置主机和端口，保证 Render 能探测到服务
ENV API_HOST=0.0.0.0
ENV API_PORT=${PORT:-8000}

# =========================
# Stage 6 — 启动应用
# =========================
# 使用 uv 运行主程序
# 不再复制 .env.example，因此不会覆盖 Render 的环境变量
CMD ["uv", "run", "python", "-m", "valuecell.server.main"]
