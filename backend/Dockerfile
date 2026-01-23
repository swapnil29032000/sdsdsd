# -------- Builder stage --------
FROM python:3.12-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip
RUN pip install django django-cors-headers psycopg2-binary

COPY . .

# -------- Runtime stage --------
FROM python:3.12-slim

WORKDIR /app

RUN useradd -m appuser
USER appuser

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBUG=0

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
