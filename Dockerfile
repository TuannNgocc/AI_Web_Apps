# ---------- Stage 1: Build React ----------
FROM node:22-slim AS web

WORKDIR /web

COPY web/package*.json ./
RUN npm install --no-audit --no-fund

COPY web/ ./
RUN npm run build


# ---------- Stage 2: FastAPI ----------
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir torch torchvision \
        --index-url https://download.pytorch.org/whl/cpu \
    && pip install --no-cache-dir -r requirements.txt

COPY config.py ./
COPY core/ core/
COPY api/ api/
COPY artifacts/ artifacts/

COPY --from=web /web/dist web/dist

ENV APP_ROOT=/app
ENV HF_HOME=/app/.cache
ENV ENABLED_MODELS=detector

RUN useradd -m app \
    && chown -R app:app /app

USER app

EXPOSE 8000

CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
