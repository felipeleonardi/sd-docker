#!/bin/bash
set -e

cd /app

chmod +x webui.sh

exec ./webui.sh \
    --listen \
    --port 7860 \
    --always-offload-from-vram \
    --precision full \
    --no-half \
    --skip-torch-cuda-test \
    --enable-insecure-extension-access
