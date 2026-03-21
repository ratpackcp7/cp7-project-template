FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ app/
COPY serve.py .
COPY .env .env
RUN mkdir -p data
EXPOSE PROJECT_PORT
CMD ["python", "serve.py"]
