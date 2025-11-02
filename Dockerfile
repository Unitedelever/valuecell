FROM python:3.11-slim

# 安装基础工具 + unzip（关键！）
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv（Python 包管理）——它会装到 /root/.local/bin 里
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# 安装 bun（前端）
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

WORKDIR /app
COPY . /app

# 先复制一份 env 模板
RUN cp .env.example .env

# 安装 Python 依赖
RUN uv sync

# 构建前端
WORKDIR /app/frontend
RUN bun install && bun run build

# 回到根目录
WORKDIR /app

EXPOSE 1420

# 启动。这里兼容 Render 的 PORT
CMD ["sh", "-c", "export PORT=${PORT:-1420} && bash start.sh"]

