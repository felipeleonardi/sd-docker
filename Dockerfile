FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3-pip \
    git \
    wget \
    curl \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    libcairo2-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Make python3.10 the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Disable build isolation globally so legacy packages (like CLIP) build correctly
RUN echo "[global]" > /etc/pip.conf \
    && echo "no-build-isolation = true" >> /etc/pip.conf

RUN pip3 install --upgrade "setuptools" "wheel"

# Create non-root user (webui.sh refuses to run as root)
RUN useradd -m -u 1000 -s /bin/bash forge

# Clone Stable Diffusion WebUI Forge as the forge user
RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git /app \
    && chown -R forge:forge /app

WORKDIR /app

# Create volume directories with correct ownership
RUN mkdir -p /app/models/Stable-diffusion \
             /app/models/Lora \
             /app/models/VAE \
             /app/models/VAE-approx \
             /app/models/ControlNet \
             /app/models/hypernetworks \
             /app/models/GFPGAN \
             /app/models/Codeformer \
             /app/models/RealESRGAN \
             /app/outputs \
             /app/embeddings \
             /app/extensions \
    && chown -R forge:forge /app/models /app/outputs /app/embeddings /app/extensions

USER forge

# Pre-create the venv and install CLIP (required by WebUI Forge)
RUN python3 -m venv /app/venv \
    && /app/venv/bin/pip install --upgrade pip \
    && /app/venv/bin/pip install "setuptools<71" wheel \
    && /app/venv/bin/pip install "numpy<2.0" \
    && /app/venv/bin/pip install --no-build-isolation \
        "https://github.com/openai/CLIP/archive/d50d76daa670286dd6cacf3bcd80b5e4823fc8e1.zip" \
    && /app/venv/bin/pip install --upgrade "pillow>=10.0.0"

# Copy entrypoint after the venv layer — keeps the expensive cache above intact
# on future entrypoint-only changes. sed strips Windows CRLF line endings.
COPY --chown=forge:forge entrypoint.sh /app/entrypoint.sh
RUN sed -i 's/\r$//' /app/entrypoint.sh && chmod +x /app/entrypoint.sh

EXPOSE 7860

ENTRYPOINT ["/app/entrypoint.sh"]
