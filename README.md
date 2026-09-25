# AI Web Apps — Streamlit & React

Bốn ứng dụng AI (phân loại ảnh, phát hiện đối tượng, tìm kiếm ảnh, chatbot RAG) sau một backend FastAPI,
với hai giao diện: Streamlit và React.

## Chạy trên máy (Python 3.11, Node 22)
```bash
pip install -r requirements.txt
uvicorn api.main:app --port 8000                  # backend + React build (nếu có web/dist)
API_URL=http://localhost:8000 streamlit run streamlit_app.py
cd web && npm install && npm run dev              # React dev server, proxy /api → 8000
python -m pytest -q tests                         # test không cần GPU
```

## Biến môi trường
| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `ENABLED_MODELS` | `classifier,detector,retrieval,llm` | Mô hình được nạp |
| `LLM_MODEL` | `Qwen/Qwen2.5-1.5B-Instruct` (GPU) / `-0.5B-` (CPU) | Mô hình sinh |
| `EMBED_MODEL` | `sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2` | Embedding cho RAG |
| `CLIP_MODEL` | `openai/clip-vit-base-patch32` | Tìm kiếm ảnh |
| `CORS_ORIGINS` | `http://localhost:5173,http://localhost:8501` | Origin được gọi API |
| `API_URL` | `http://localhost:8000` | (Streamlit) địa chỉ backend |

## Docker
```bash
docker build -t ai-web-apps . && docker run -p 8000:8000 ai-web-apps   # mở http://localhost:8000
```

Chỉ số mô hình: xem `artifacts/*/metrics.json` và `artifacts/rag_metrics.json`.

## Benchmark — AI-02 Detector

### Mô hình

- Model: YOLO11n
- Dataset đánh giá: COCO128
- Device: CPU
- Hardware: Apple M1 Pro
- Docker Desktop: 8 CPUs, 7.748 GiB memory

### API benchmark

| Endpoint | Requests | Concurrency | Success | Throughput | p50 | p95 |
|---|---:|---:|---:|---:|---:|---:|
| `/api/health` | 100 | 10 | 100/100 | 1140.69 req/s | 4.7 ms | 44.5 ms |
| `/api/detect` | 100 | 10 | 100/100 | 8.85 req/s | 1151.12 ms | 1332.14 ms |

### YOLO inference latency

| Metric | Result |
|---|---:|
| Average | 110.29 ms |
| p50 | 104.90 ms |
| p95 | 149.38 ms |
| Max | 175.10 ms |

### Docker resource snapshot

Đo sau benchmark `/api/detect`:

| Resource | Result |
|---|---:|
| CPU | 0.48% |
| Memory | 385.1 MiB / 7.748 GiB |
| Memory usage | 4.85% |
