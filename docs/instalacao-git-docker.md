# Instalação de Git e Docker

Guia passo a passo para instalar Git, Docker e o NVIDIA Container Toolkit nos principais sistemas operacionais.

---

## Sumário

- [Git](#git)
  - [Windows](#git--windows)
  - [macOS](#git--macos)
  - [Linux](#git--linux)
- [Docker](#docker)
  - [Windows](#docker--windows)
  - [macOS](#docker--macos)
  - [Linux (Ubuntu/Debian)](#docker--linux-ubuntudebian)
  - [Linux (Arch Linux)](#docker--linux-arch-linux)
  - [Linux (Fedora)](#docker--linux-fedora)
- [NVIDIA Container Toolkit](#nvidia-container-toolkit)
- [Verificação Final](#verificação-final)

---

## Git

### Git — Windows

1. Acesse [git-scm.com/download/win](https://git-scm.com/download/win)
2. Baixe o instalador e execute
3. Durante a instalação, mantenha as opções padrão (recomendado)
4. Verifique a instalação abrindo o **Git Bash** ou **Prompt de Comando**:
   ```
   git --version
   ```

**Alternativa via winget:**
```powershell
winget install --id Git.Git -e --source winget
```

---

### Git — macOS

**Via Homebrew (recomendado):**

Se não tiver o Homebrew instalado, instale primeiro:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Depois instale o Git:
```bash
brew install git
git --version
```

**Via Xcode Command Line Tools:**
```bash
xcode-select --install
```

---

### Git — Linux

**Ubuntu / Debian:**
```bash
sudo apt-get update
sudo apt-get install -y git
git --version
```

**Arch Linux:**
```bash
sudo pacman -S git
```

**Fedora:**
```bash
sudo dnf install git
```

---

## Docker

### Docker — Windows

O Docker Desktop para Windows inclui tudo que você precisa.

**Requisitos:**
- Windows 10 64-bit (versão 1903 ou posterior) ou Windows 11
- WSL 2 habilitado (o instalador configura automaticamente)
- Virtualização habilitada na BIOS

**Instalação:**

1. Acesse [docs.docker.com/desktop/install/windows-install](https://docs.docker.com/desktop/install/windows-install/)
2. Baixe o Docker Desktop Installer
3. Execute o instalador e siga as instruções
4. Reinicie o computador quando solicitado
5. Abra o Docker Desktop e aguarde inicializar
6. Verifique no terminal:
   ```
   docker --version
   docker compose version
   ```

> **Nota sobre GPU no Windows:** O suporte a GPU NVIDIA no Docker no Windows requer WSL 2. Siga as instruções em [docs.nvidia.com/cuda/wsl-user-guide](https://docs.nvidia.com/cuda/wsl-user-guide/index.html).

---

### Docker — macOS

O Docker Desktop para macOS suporta tanto chips Intel quanto Apple Silicon (M1/M2/M3).

**Requisitos:**
- macOS 12 (Monterey) ou posterior
- 4 GB de RAM mínimo

**Instalação:**

1. Acesse [docs.docker.com/desktop/install/mac-install](https://docs.docker.com/desktop/install/mac-install/)
2. Baixe a versão correta para seu chip (Intel ou Apple Silicon)
3. Abra o `.dmg` e arraste o Docker para Applications
4. Inicie o Docker Desktop pelo Launchpad
5. Verifique:
   ```bash
   docker --version
   docker compose version
   ```

**Via Homebrew:**
```bash
brew install --cask docker
```

> **Nota:** GPUs NVIDIA não são suportadas no macOS. Este projeto requer Linux com GPU NVIDIA para melhor desempenho. No macOS, o SD rodará em CPU (muito mais lento).

---

### Docker — Linux (Ubuntu/Debian)

#### Instalar Docker Engine

```bash
# Remover versões antigas se existirem
sudo apt-get remove docker docker-engine docker.io containerd runc

# Instalar dependências
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Adicionar chave GPG oficial do Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Adicionar repositório
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### Configurar permissões (sem precisar de sudo)

```bash
sudo usermod -aG docker $USER
newgrp docker
```

> Faça logout e login para as permissões tomarem efeito, ou use `newgrp docker` na sessão atual.

#### Verificar instalação

```bash
docker --version
docker compose version
docker run hello-world
```

---

### Docker — Linux (Arch Linux)

```bash
sudo pacman -S docker docker-compose

# Iniciar e habilitar o serviço
sudo systemctl enable --now docker

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker

# Verificar
docker --version
docker run hello-world
```

---

### Docker — Linux (Fedora)

```bash
# Instalar
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Iniciar e habilitar
sudo systemctl enable --now docker

# Permissões
sudo usermod -aG docker $USER
newgrp docker

# Verificar
docker run hello-world
```

---

## NVIDIA Container Toolkit

O NVIDIA Container Toolkit permite que containers Docker acessem a GPU do host. **Necessário apenas no Linux.**

### Pré-requisito: drivers NVIDIA instalados

Verifique se os drivers estão instalados:
```bash
nvidia-smi
```

Se não estiver instalado, instale os drivers para sua distribuição antes de continuar.

### Instalação (Ubuntu/Debian)

```bash
# Adicionar repositório NVIDIA
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Instalar
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Configurar o Docker para usar o runtime NVIDIA
sudo nvidia-ctk runtime configure --runtime=docker

# Reiniciar o Docker
sudo systemctl restart docker
```

### Instalação (Arch Linux)

```bash
# Via AUR
yay -S nvidia-container-toolkit

# Configurar
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Instalação (Fedora)

```bash
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
  sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

sudo dnf install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

---

## Verificação Final

Após instalar tudo, verifique se a GPU está acessível dentro do Docker:

```bash
docker run --rm --gpus all nvidia/cuda:12.1.1-base-ubuntu22.04 nvidia-smi
```

A saída deve mostrar uma tabela com o nome da sua GPU, versão do driver e uso de memória. Se aparecer, está tudo configurado corretamente.

**Exemplo de saída esperada:**
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 535.104.12   Driver Version: 535.104.12   CUDA Version: 12.2    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0  On |                  N/A |
|  0%   45C    P8    10W / 200W |    500MiB /  8192MiB |      0%      Default |
+-----------------------------------------------------------------------------+
```

Se aparecer erro, verifique:
1. `nvidia-smi` funciona no host (sem Docker)
2. O NVIDIA Container Toolkit está instalado
3. O Docker foi reiniciado após a configuração do toolkit
4. Seu usuário está no grupo `docker`

---

Após concluir a instalação, retorne ao [README principal](../README.md) para iniciar o projeto.
