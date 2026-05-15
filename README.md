<div align="center">
  <img src="tmp/sd.png" alt="Stable Diffusion" width="600"/>
</div>

# Stable Diffusion WebUI Forge — Docker com GPU NVIDIA

Rode o [Stable Diffusion WebUI Forge](https://github.com/lllyasviel/stable-diffusion-webui-forge) dentro de um container Docker com suporte a GPU NVIDIA. Gere imagens de alta qualidade com uma interface web completa, sem precisar instalar dependências diretamente no seu sistema.

---

## Sumário

- [Ferramentas Necessárias](#ferramentas-necessárias)
- [Modelos e Arquivos Necessários](#modelos-e-arquivos-necessários)
- [Como Iniciar o Projeto](#como-iniciar-o-projeto)
- [Como Usar o Stable Diffusion](#como-usar-o-stable-diffusion)
- [Instalação de Git e Docker](#instalação-de-git-e-docker)
- [Como Contribuir](#como-contribuir)
- [Como Abrir um Bug](#como-abrir-um-bug)

---

## Ferramentas Necessárias

Para rodar este projeto você precisa de:

| Ferramenta | Versão mínima | Descrição |
|---|---|---|
| **Git** | 2.x | Para clonar e versionar o projeto |
| **Docker** | 24.x | Para rodar o container |
| **NVIDIA Driver** | 525+ | Para uso da GPU |
| **NVIDIA Container Toolkit** | 1.14+ | Para acesso à GPU dentro do Docker |

> Consulte o guia completo de instalação: [docs/instalacao-git-docker.md](docs/instalacao-git-docker.md)

---

## Modelos e Arquivos Necessários

O Stable Diffusion precisa de modelos (arquivos pesados) que **não são incluídos neste repositório**. Você deve baixá-los e colocá-los nas pastas corretas antes de iniciar.

### Estrutura de pastas de modelos

```
sd-docker/
├── models/
│   ├── Stable-diffusion/   ← Checkpoints principais (obrigatório)
│   ├── Lora/               ← LoRAs para fine-tuning de estilo/personagem
│   ├── VAE/                ← Variational Autoencoders (melhora cores e detalhes)
│   ├── VAE-approx/         ← VAE aproximado (uso interno do WebUI)
│   ├── ControlNet/         ← Modelos de controle de pose/borda/profundidade
│   ├── hypernetworks/      ← Hypernetworks (estilo alternativo ao LoRA)
│   ├── GFPGAN/             ← Restauração de rostos
│   ├── Codeformer/         ← Restauração de rostos (alternativo)
│   └── RealESRGAN/         ← Upscaling de imagens
└── embeddings/             ← Textual Inversions
```

---

### Checkpoints (obrigatório)

Coloque arquivos `.safetensors` ou `.ckpt` em `models/Stable-diffusion/`.

| Modelo | Link | Notas |
|---|---|---|
| **Stable Diffusion 1.5** | [HuggingFace](https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors) | Base oficial, uso geral |
| **DreamShaper 8** | [CivitAI](https://civitai.com/models/4384/dreamshaper) | Fotorrealismo e fantasia |
| **Realistic Vision v6** | [CivitAI](https://civitai.com/models/4201/realistic-vision-v60-b1) | Fotorrealismo avançado |
| **Anything v5** | [CivitAI](https://civitai.com/models/9409/or-anything-v5) | Estilo anime |

---

### VAE (recomendado)

Coloque em `models/VAE/`. Melhora significativamente as cores e detalhes das imagens.

| Modelo | Link | Notas |
|---|---|---|
| **vae-ft-mse-840000** | [HuggingFace](https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors) | VAE padrão para SD 1.5 |
| **ClearVAE** | [CivitAI](https://civitai.com/models/22354/clearvae) | Maior nitidez |

---

### ControlNet (opcional, mas muito útil)

Coloque em `models/ControlNet/`. Permite controlar pose, bordas, profundidade e mais.

| Modelo | Link | Notas |
|---|---|---|
| **ControlNet SD1.5 (coleção)** | [HuggingFace](https://huggingface.co/lllyasviel/sd_control_collection) | Coleção completa |
| **OpenPose** | [HuggingFace](https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_mid.safetensors) | Controle de pose corporal |
| **Canny** | [HuggingFace](https://huggingface.co/lllyasviel/ControlNet/resolve/main/models/control_sd15_canny.pth) | Controle por bordas |
| **Depth** | [HuggingFace](https://huggingface.co/lllyasviel/ControlNet/resolve/main/models/control_sd15_depth.pth) | Controle por mapa de profundidade |

---

### LoRA (opcional)

Coloque arquivos `.safetensors` em `models/Lora/`. Modifique estilos, personagens e conceitos específicos.

Explore LoRAs em [CivitAI — LoRA](https://civitai.com/models?types=LORA).

---

### Embeddings / Textual Inversions (opcional)

Coloque em `embeddings/`. Definem conceitos específicos em poucos tokens.

Explore embeddings em [CivitAI — Embeddings](https://civitai.com/models?types=TextualInversion) e no [HuggingFace Concepts Library](https://huggingface.co/sd-concepts-library).

---

## Como Iniciar o Projeto

### 1. Clone o repositório

```bash
git clone https://github.com/felipedamaro/sd-docker.git
cd sd-docker
```

### 2. Baixe pelo menos um checkpoint

Coloque um arquivo `.safetensors` em `models/Stable-diffusion/` antes de continuar (veja a seção [Modelos](#modelos-e-arquivos-necessários)).

---

### Opção A — Via script `sd.sh` (recomendado)

O script verifica se o Docker está ativo, cria os diretórios necessários e gerencia o container automaticamente.

```bash
# Iniciar
./sd.sh start

# Parar
./sd.sh stop

# Reconstruir a imagem do zero (após alterar o Dockerfile)
./sd.sh rebuild
```

Após iniciar, aguarde a mensagem `Running on local URL: http://0.0.0.0:7860` nos logs e acesse:

```
http://localhost:7860
```

> **Nota:** A primeira execução faz o build da imagem Docker (~1.5 GB de download) e instala as dependências do PyTorch (~5-10 GB). Pode levar 20-40 minutos dependendo da sua conexão.

---

### Opção B — Via Docker Compose manualmente

```bash
# Primeira execução (build + start)
docker compose up --build

# Execuções seguintes em background
docker compose up -d

# Ver logs em tempo real
docker compose logs -f forge

# Parar o container
docker compose down
```

---

### Comandos úteis

```bash
# Verificar se o container está rodando
docker ps

# Ver uso de GPU em tempo real
watch -n 1 nvidia-smi

# Acessar o shell do container
docker exec -it sd-forge bash
```

---

## Como Usar o Stable Diffusion

Consulte a documentação detalhada sobre todas as funcionalidades da interface:

**[docs/como-usar-o-sd.md](docs/como-usar-o-sd.md)**

Inclui:
- txt2img, img2img, inpainting
- Como usar checkpoints, VAE, LoRA e ControlNet
- Como instalar extensões
- Dicas de prompts

---

## Instalação de Git e Docker

Guia passo a passo para instalar as ferramentas necessárias no seu sistema operacional:

**[docs/instalacao-git-docker.md](docs/instalacao-git-docker.md)**

Cobre Windows, macOS e Linux (Ubuntu/Debian, Arch, Fedora), incluindo a instalação do NVIDIA Container Toolkit.

---

## Como Contribuir

Contribuições são bem-vindas! Siga as boas práticas abaixo para manter o projeto organizado.

### Fluxo de contribuição

1. **Fork** o repositório clicando em `Fork` no GitHub
2. **Clone** seu fork localmente:
   ```bash
   git clone https://github.com/SEU-USUARIO/sd-docker.git
   cd sd-docker
   ```
3. **Crie uma branch** descritiva para sua mudança:
   ```bash
   git checkout -b feat/nome-da-funcionalidade
   # ou
   git checkout -b fix/descricao-do-bug
   ```
4. **Faça suas alterações** seguindo as convenções do projeto
5. **Commit** com mensagens claras no padrão [Conventional Commits](https://www.conventionalcommits.org/):
   ```bash
   git commit -m "feat: adiciona suporte a múltiplas GPUs"
   git commit -m "fix: corrige erro de permissão no entrypoint"
   git commit -m "docs: atualiza instruções de ControlNet"
   ```
6. **Push** para seu fork:
   ```bash
   git push origin feat/nome-da-funcionalidade
   ```
7. **Abra um Pull Request** no repositório original com:
   - Título claro descrevendo a mudança
   - Descrição do que foi alterado e por quê
   - Screenshots se for uma mudança visual

### Diretrizes

- Mantenha o escopo focado: um PR por funcionalidade ou correção
- Não commite modelos, imagens geradas ou arquivos `.ckpt`/`.safetensors`
- Teste suas mudanças antes de abrir o PR
- Documente novas funcionalidades

---

## Como Abrir um Bug

Encontrou um problema? Abra uma issue seguindo as boas práticas:

1. **Verifique se já existe** uma issue similar em [Issues](../../issues) antes de criar uma nova
2. **Clique em "New Issue"** e use o template de bug report
3. **Inclua as seguintes informações:**
   - **Descrição:** O que aconteceu vs. o que era esperado
   - **Passos para reproduzir:** Lista numerada e detalhada
   - **Ambiente:**
     ```
     OS: Ubuntu 22.04
     GPU: NVIDIA RTX 3080 (10 GB VRAM)
     Driver NVIDIA: 535.x
     Docker: 24.x
     ```
   - **Logs de erro:** Cole a saída de `docker compose logs forge` ou `./sd.sh start`
   - **Screenshots:** Se aplicável

### Exemplo de boa issue

```
Título: Container não inicia — erro "CUDA not found" mesmo com GPU detectada

Descrição:
Ao rodar ./sd.sh start, o container sobe mas o WebUI falha ao inicializar
com erro "RuntimeError: CUDA not found".

Passos para reproduzir:
1. Clone o repositório
2. Coloque um checkpoint em models/Stable-diffusion/
3. Execute ./sd.sh start
4. Aguarde o build e observe os logs

Ambiente:
OS: Ubuntu 22.04 LTS
GPU: NVIDIA RTX 2070 (8 GB)
Driver: 525.105.17
Docker: 24.0.5
NVIDIA Container Toolkit: 1.14.0

Logs:
[cole aqui a saída de: docker compose logs forge]
```
