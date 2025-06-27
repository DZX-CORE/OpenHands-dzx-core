# Usar imagem oficial python leve
FROM python:3.12-slim

# Definir diretório de trabalho
WORKDIR /app

# Evitar cache pesado do pip
ENV PIP_NO_CACHE_DIR=1

# Instalar dependências do sistema necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar poetry sem criar virtualenvs e desabilitar parallel para menos uso de RAM
RUN pip install --upgrade pip poetry && \
    poetry config virtualenvs.create false && \
    poetry config installer.parallel false

# Copiar arquivos de dependências
COPY pyproject.toml poetry.lock* /app/

# Instalar só dependências de produção (sem dev)
RUN poetry install --no-dev --only main

# Copiar o código fonte
COPY . /app

# Expor porta da app (ajuste conforme seu app)
EXPOSE 8000

# Comando para rodar o Uvicorn com hot reload desativado (modo produção)
CMD ["uvicorn", "openhands.server.app:app", "--host", "0.0.0.0", "--port", "8000"]