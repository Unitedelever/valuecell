FROM python:3.11-slim

# 安装基础工具
RUN apt-get update && apt-get install -y curl git build-essential && rm -rf /var/lib/apt/lists/*

# 安装 uv（Python 包管理）
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:${PATH}"

# 安装 bun（前端）
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

WORKDIR /app
COPY . /app

# 先复制一份 env 模板，等下在 Render 里再配真正的
RUN cp .env.example .env

# 安装 Python 依赖
RUN uv sync

# 构建前端
WORKDIR /app/frontend
RUN bun install && bun run build

# 回到根目录
WORKDIR /app

# 项目默认开在 1420
EXPOSE 1420

# 启动
CMD ["bash", "start.sh"]
