# 1. Build do frontend com Node.js
FROM node:18 AS frontend
WORKDIR /app/frontend
COPY frontend/ .
RUN npm install && npm run build

# 2. App Python com FastAPI
FROM python:3.12-slim
WORKDIR /app

# Instala dependências de sistema
RUN apt update && apt install -y ffmpeg git curl build-essential libmagic1 && \
    rm -rf /var/lib/apt/lists/*

# Copia código completo
COPY . .

# Instala Poetry e dependências Python
RUN pip install --upgrade pip poetry && \
    poetry config virtualenvs.create false && \
    poetry install --no-dev

# Copia build frontend para servir arquivos estáticos
COPY --from=frontend /app/frontend/dist frontend/dist

# Configura porta
EXPOSE 8000

# Comando padrão para iniciar o backend (serve também frontend)
CMD ["uvicorn", "openhands.server.app:app", "--host", "0.0.0.0", "--port", "8000"]