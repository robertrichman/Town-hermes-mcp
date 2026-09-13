FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN addgroup --system hermes-mcp \
    && adduser --system --ingroup hermes-mcp --home /home/hermes-mcp hermes-mcp

WORKDIR /app

COPY pyproject.toml README.md LICENSE ./
COPY src ./src

RUN python -m pip install --no-cache-dir .

USER hermes-mcp

EXPOSE 8765

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8765/.well-known/oauth-authorization-server', timeout=4).read()"]

CMD ["hermes-mcp", "serve"]
