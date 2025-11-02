FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl git python3 python3-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

RUN test -f .env.example && cp .env.example .env || true

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app/python
RUN uv sync

WORKDIR /app/python
EXPOSE 8000
CMD ["uv", "run", "python", "-m", "valuecell.server.main"]
