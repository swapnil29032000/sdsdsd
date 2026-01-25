# -------- Builder stage --------
FROM python:3.12-slim AS builder

WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    build-essential gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install django django-cors-headers psycopg2-binary

# Copy project source (venv is ignored via .dockerignore)
COPY . .

# -------- Runtime stage --------
FROM python:3.12-slim

WORKDIR /app

# Create non-root user
RUN useradd -m appuser

# Copy venv and app from builder
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

# Permissions
RUN chown -R appuser:appuser /app /opt/venv

USER appuser

# Environment variables
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=config.settings

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
