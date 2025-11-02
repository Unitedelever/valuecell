FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    python3-venv \
    python3-pip \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

WORKDIR /app
COPY . /app

# optional: copy env template
RUN cp .env.example .env || true

# ---- backend deps ----
WORKDIR /app/python
RUN uv sync

# ---- frontend build (comment out if repo has no /frontend) ----
WORKDIR /app/frontend
RUN bun install
RUN bun run build

# ---- run server ----
WORKDIR /app/python
EXPOSE 8000
CMD ["uv", "run", "python", "-m", "valuecell.api"]
