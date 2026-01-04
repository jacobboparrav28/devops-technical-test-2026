FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# No root user 
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r  requirements.txt

COPY . .

USER appuser

#Perfect port for Kubernetes
EXPOSE 8080 

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]