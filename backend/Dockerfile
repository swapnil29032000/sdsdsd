# ---- builder stage ----
    FROM python:3.12-slim AS builder
    WORKDIR /app
    
    COPY requirements.txt .
    RUN pip wheel --no-cache-dir --wheel-dir /app/wheels -r requirements.txt
    
    # ---- runtime stage ----
    FROM python:3.12-slim
    WORKDIR /app
    
    COPY --from=builder /app/wheels /wheels
    RUN pip install --no-cache /wheels/*.whl
    
    COPY . .
    CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
    