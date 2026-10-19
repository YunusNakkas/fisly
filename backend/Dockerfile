# Fişly backend — production image (Fly.io)
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Bağımlılıkları önce kur (layer cache).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama kodu + migration'lar.
COPY app ./app
COPY alembic ./alembic
COPY alembic.ini .

# Root olmayan kullanıcı; logs/ yazılabilir olmalı.
RUN useradd -m -u 1000 fisly \
    && mkdir -p /app/logs /app/uploads \
    && chown -R fisly:fisly /app
USER fisly

EXPOSE 8080

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
