#!/bin/bash

COMPOSE_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER_NAME="sd-forge"
SERVICE_NAME="forge"
WEBUI_URL="http://localhost:7860"

usage() {
    echo "Uso: $0 {start|stop|rebuild}"
    echo ""
    echo "  start    Inicia o Docker (se necessário) e o container $CONTAINER_NAME"
    echo "  stop     Para o container $CONTAINER_NAME"
    echo "  rebuild  Para o container, reconstrói a imagem do zero e inicia novamente"
}

ensure_docker_running() {
    local os
    case "$(uname -s)" in
        Linux*)              os="linux" ;;
        Darwin*)             os="macos" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *)                   os="unknown" ;;
    esac

    if docker info &>/dev/null; then
        return 0
    fi

    case "$os" in
        linux)
            echo "Docker não está ativo. Iniciando..."
            sudo systemctl start docker
            echo -n "Aguardando Docker iniciar"
            for i in $(seq 1 10); do
                sleep 1
                echo -n "."
                if docker info &>/dev/null; then
                    echo " OK"
                    return 0
                fi
            done
            echo ""
            echo "Erro: Docker não iniciou a tempo." >&2
            exit 1
            ;;
        macos)
            echo "Docker não está ativo. Iniciando Docker Desktop..."
            open -a Docker
            echo -n "Aguardando Docker iniciar"
            for i in $(seq 1 15); do
                sleep 2
                echo -n "."
                if docker info &>/dev/null; then
                    echo " OK"
                    return 0
                fi
            done
            echo ""
            echo "Erro: Docker Desktop não iniciou a tempo." >&2
            exit 1
            ;;
        windows|*)
            echo "Docker não está respondendo." >&2
            echo "Por favor, inicie o Docker Desktop manualmente e tente novamente." >&2
            exit 1
            ;;
    esac
}

is_container_running() {
    docker ps --filter "name=^/${CONTAINER_NAME}$" --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"
}

cmd_start() {
    ensure_docker_running

    if is_container_running; then
        echo "Container '$CONTAINER_NAME' já está rodando."
        echo "WebUI disponível em: $WEBUI_URL"
        echo ""
        echo "Acompanhar logs? (Ctrl+C para sair)"
        docker compose -f "$COMPOSE_DIR/docker-compose.yml" logs -f "$SERVICE_NAME"
        return
    fi

    mkdir -p "$COMPOSE_DIR/models/Stable-diffusion" \
             "$COMPOSE_DIR/models/Lora" \
             "$COMPOSE_DIR/models/VAE" \
             "$COMPOSE_DIR/models/VAE-approx" \
             "$COMPOSE_DIR/models/ControlNet" \
             "$COMPOSE_DIR/models/hypernetworks" \
             "$COMPOSE_DIR/models/GFPGAN" \
             "$COMPOSE_DIR/models/Codeformer" \
             "$COMPOSE_DIR/models/RealESRGAN" \
             "$COMPOSE_DIR/outputs" \
             "$COMPOSE_DIR/embeddings" \
             "$COMPOSE_DIR/extensions"

    echo "Iniciando container '$CONTAINER_NAME'..."
    docker compose -f "$COMPOSE_DIR/docker-compose.yml" up -d --build

    if is_container_running; then
        echo ""
        echo "Container iniciado com sucesso!"
        echo "WebUI disponível em: $WEBUI_URL"
        echo ""
        echo "Exibindo logs (Ctrl+C para sair sem parar o container)..."
        docker compose -f "$COMPOSE_DIR/docker-compose.yml" logs -f "$SERVICE_NAME"
    else
        echo "Erro: Container não iniciou corretamente." >&2
        docker compose -f "$COMPOSE_DIR/docker-compose.yml" logs "$SERVICE_NAME"
        exit 1
    fi
}

cmd_stop() {
    ensure_docker_running

    if ! is_container_running; then
        echo "Container '$CONTAINER_NAME' já está parado."
        return
    fi

    echo "Parando container '$CONTAINER_NAME'..."
    docker compose -f "$COMPOSE_DIR/docker-compose.yml" down
    echo "Container parado."
}

cmd_rebuild() {
    ensure_docker_running

    if is_container_running; then
        echo "Parando container '$CONTAINER_NAME'..."
        docker compose -f "$COMPOSE_DIR/docker-compose.yml" down
    fi

    echo "Reconstruindo imagem do zero (--no-cache)..."
    docker compose -f "$COMPOSE_DIR/docker-compose.yml" build --no-cache

    cmd_start
}

case "$1" in
    start)   cmd_start   ;;
    stop)    cmd_stop    ;;
    rebuild) cmd_rebuild ;;
    *)       usage; exit 1 ;;
esac
