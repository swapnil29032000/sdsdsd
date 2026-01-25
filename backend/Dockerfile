# ---------- Build Stage ----------
FROM python:3.11-slim AS builder

WORKDIR /app
RUN apt-get update && apt-get install -y build-essential

COPY requirements.txt .
RUN pip install --user -r requirements.txt


# ---------- Runtime Stage ----------
FROM python:3.11-slim

WORKDIR /app

# Create non-root user
RUN useradd -m appuser

COPY --from=builder /root/.local /home/appuser/.local
COPY . .

# 🔑 THIS IS THE FIX
RUN chown -R appuser:appuser /app

ENV PATH=/home/appuser/.local/bin:$PATH

USER appuser

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

