# Como Usar o Stable Diffusion WebUI Forge

Este guia cobre o funcionamento básico do Stable Diffusion e da interface WebUI Forge, desde a geração de imagens por texto até técnicas avançadas com LoRA, ControlNet e extensões.

---

## Sumário

- [O que é o Stable Diffusion](#o-que-é-o-stable-diffusion)
- [Acessando a Interface](#acessando-a-interface)
- [Visão Geral da Interface](#visão-geral-da-interface)
- [txt2img — Texto para Imagem](#txt2img--texto-para-imagem)
- [img2img — Imagem para Imagem](#img2img--imagem-para-imagem)
- [Inpainting — Edição de Áreas](#inpainting--edição-de-áreas)
- [Extras — Upscaling e Restauração de Rostos](#extras--upscaling-e-restauração-de-rostos)
- [Modelos e Arquivos](#modelos-e-arquivos)
  - [Checkpoints](#checkpoints)
  - [VAE](#vae)
  - [LoRA](#lora)
  - [ControlNet](#controlnet)
  - [Embeddings / Textual Inversions](#embeddings--textual-inversions)
  - [Hypernetworks](#hypernetworks)
- [Instalando Extensões e Plugins](#instalando-extensões-e-plugins)
- [Dicas de Prompts](#dicas-de-prompts)

---

## O que é o Stable Diffusion

**Stable Diffusion** é um modelo de inteligência artificial de código aberto para geração de imagens a partir de texto (e outras entradas). Ele utiliza um processo chamado **difusão latente**: começa com ruído aleatório e, iterativamente, refina a imagem guiado pelo texto fornecido.

**WebUI Forge** é uma interface gráfica baseada no [AUTOMATIC1111 WebUI](https://github.com/AUTOMATIC1111/stable-diffusion-webui), otimizada para melhor desempenho e uso de VRAM. Ela expõe todas as funcionalidades do SD em uma interface web acessível pelo navegador.

---

## Acessando a Interface

Com o container rodando (veja o [README](../README.md)), acesse no navegador:

```
http://localhost:7860
```

Aguarde a mensagem `Running on local URL: http://0.0.0.0:7860` nos logs antes de tentar acessar. Na primeira inicialização, o WebUI baixa automaticamente PyTorch e outras dependências — isso pode levar 20-40 minutos.

---

## Visão Geral da Interface

A interface possui abas na parte superior:

| Aba | Função |
|---|---|
| **txt2img** | Gerar imagem a partir de texto |
| **img2img** | Transformar uma imagem existente |
| **Extras** | Upscaling, restauração de rostos |
| **PNG Info** | Ler metadados de imagens geradas |
| **Checkpoint Merger** | Mesclar dois checkpoints |
| **Train** | Treinar embeddings e hypernetworks |
| **Settings** | Configurações gerais |
| **Extensions** | Gerenciar extensões instaladas |

No topo da página há um seletor de **Checkpoint** (modelo principal) e um seletor de **VAE**.

---

## txt2img — Texto para Imagem

A aba principal. Descreva o que você quer gerar e o modelo cria a imagem do zero.

### Campos principais

**Prompt positivo** — Descreva o que deve aparecer na imagem:
```
a beautiful landscape, mountains in the background, golden hour, photorealistic, 8k, detailed
```

**Prompt negativo** — Descreva o que NÃO deve aparecer:
```
blurry, low quality, watermark, text, deformed, ugly, bad anatomy
```

### Parâmetros

| Parâmetro | Descrição | Valor típico |
|---|---|---|
| **Sampling method** | Algoritmo de geração (sampler) | DPM++ 2M Karras, Euler a |
| **Sampling steps** | Número de iterações de refinamento | 20–30 |
| **CFG Scale** | Quão fiel à descrição (maior = mais literal) | 7–12 |
| **Width / Height** | Dimensão da imagem em pixels | 512×512, 768×512 |
| **Batch count** | Quantas rodadas de geração | 1 |
| **Batch size** | Quantas imagens por rodada | 1–4 |
| **Seed** | Valor de aleatoriedade (-1 = aleatório) | -1 ou fixo para reproduzir |

### Dicas

- Use **512×512** para SD 1.5 (tamanho nativo). Tamanhos maiores funcionam mas podem gerar artefatos.
- **CFG Scale 7** é um bom ponto de partida. Valores muito altos distorcem a imagem.
- **20 steps** com DPM++ 2M Karras produz bons resultados com rapidez.
- Clique em **Generate** e aguarde. Imagens são salvas em `outputs/`.

### Hires Fix

Permite gerar em alta resolução em dois passos (mais qualidade, mais tempo):

1. Marque **Hires Fix**
2. Defina o **Upscale by** (ex: 2x)
3. Escolha o upscaler (R-ESRGAN 4x+ é boa opção)
4. Ajuste **Denoising strength** (0.5–0.7 é comum)

---

## img2img — Imagem para Imagem

Transforma uma imagem existente guiada por um prompt. Útil para:
- Mudar estilo de uma foto (ex: "anime style, vibrant colors")
- Adicionar elementos a uma imagem existente
- Fazer variações de uma imagem gerada

### Como usar

1. Acesse a aba **img2img**
2. Arraste ou clique para enviar sua imagem
3. Escreva o prompt descrevendo o resultado desejado
4. Ajuste o **Denoising strength**:
   - **0.1–0.3:** Mudanças sutis, imagem original bem preservada
   - **0.4–0.6:** Equilíbrio entre original e novo prompt
   - **0.7–1.0:** Grandes mudanças, imagem original pouco reconhecível

### Sketch

Dentro do img2img, o modo **Sketch** permite desenhar sobre a imagem com pincel colorido antes de processar.

---

## Inpainting — Edição de Áreas

Edite apenas partes específicas de uma imagem, mantendo o resto intacto.

### Como usar

1. Acesse a aba **img2img** → subtab **Inpaint**
2. Envie a imagem que quer editar
3. **Pinte com o pincel** a área que quer substituir (fica azul)
4. Escreva o prompt descrevendo o que deve aparecer na área pintada
5. Ajuste os parâmetros:
   - **Mask blur:** Suaviza as bordas da máscara (4–8 é bom)
   - **Inpaint area:** `Only masked` é mais preciso para objetos pequenos
   - **Denoising strength:** 0.75–0.85 para mudanças visíveis mas coerentes

### Casos de uso comuns

- Trocar o rosto de um personagem
- Remover ou adicionar objetos
- Mudar roupas, cores, texturas
- Corrigir defeitos em imagens geradas

---

## Extras — Upscaling e Restauração de Rostos

### Upscaling

Aumenta a resolução de uma imagem com qualidade superior ao simples redimensionamento.

1. Acesse a aba **Extras**
2. Envie a imagem
3. Escolha o **Resize** (ex: 2x, 4x)
4. Selecione o **Upscaler 1** (R-ESRGAN 4x+ é recomendado para fotos)
5. Clique em **Generate**

Upscalers disponíveis:
- **R-ESRGAN 4x+** — Fotos realistas
- **R-ESRGAN 4x+ Anime6B** — Imagens no estilo anime
- **ESRGAN_4x** — Uso geral
- **Latent** — Interno do SD, mais experimental

### Restauração de Rostos

Melhora automaticamente rostos que saíram deformados ou pouco detalhados.

**Na geração (txt2img/img2img):** Marque **Restore faces** antes de gerar. Escolha entre:
- **GFPGAN** — Mais rápido, bom resultado geral
- **CodeFormer** — Geralmente mais detalhado (ajuste o slider de fidelidade)

**Na aba Extras:** Envie a imagem e marque **Restore faces**.

---

## Modelos e Arquivos

### Checkpoints

O **checkpoint** (ou model) é o "cérebro" do Stable Diffusion. Define o estilo base, o vocabulário visual e as capacidades do modelo.

**Onde colocar:** `models/Stable-diffusion/`  
**Extensões:** `.safetensors` (preferido) ou `.ckpt`

**Como usar:** No topo da interface, clique no seletor de checkpoint e escolha o modelo. Clique no ícone de refresh se não aparecer na lista.

**Tipos comuns:**
- **Base SD 1.5:** Uso geral, compatível com a maioria das extensões
- **Modelos fotorrealistas:** (ex: Realistic Vision) — otimizados para simular fotos
- **Modelos de anime/ilustração:** (ex: Anything, DreamShaper) — para estilos artísticos
- **SDXL:** Versão maior, gera imagens mais detalhadas (requer mais VRAM)

---

### VAE

O **VAE** (Variational Autoencoder) é um componente que converte a imagem do espaço latente (interno do modelo) para pixels. Usar um VAE adequado melhora muito as cores e os detalhes finos.

**Onde colocar:** `models/VAE/`  
**Extensões:** `.safetensors` ou `.pt`

**Como usar:** No seletor de VAE no topo da interface (ao lado do checkpoint).

**Recomendação:** Para SD 1.5, use `vae-ft-mse-840000-ema-pruned.safetensors`.

**Sem VAE:** A imagem pode sair com cores lavadas ou acinzentadas — isso é normal sem VAE.

---

### LoRA

**LoRA** (Low-Rank Adaptation) é um arquivo pequeno de fine-tuning que "treina" o modelo em um conceito específico — um estilo artístico, um personagem, um objeto, uma técnica fotográfica — sem alterar o checkpoint base.

**Onde colocar:** `models/Lora/`  
**Extensões:** `.safetensors`

**Como usar no prompt:**
```
a woman in a park, <lora:my-lora-name:0.8>
```
Onde `0.8` é o **peso** (0.0 a 1.0 — geralmente 0.6–0.9 funciona bem).

**Como visualizar LoRAs disponíveis:** No prompt, clique no ícone de pasta/LoRA abaixo do campo de texto para abrir o browser de LoRAs.

---

### ControlNet

**ControlNet** adiciona condicionamento espacial à geração: controla onde exatamente os elementos aparecem na imagem usando um mapa guia (pose corporal, bordas, profundidade, etc.).

**Onde colocar:** `models/ControlNet/`

**Como usar:**
1. Na aba txt2img ou img2img, expanda o painel **ControlNet**
2. Faça upload da imagem guia
3. Selecione o **Control Type** (Canny, Depth, OpenPose, etc.)
4. O modelo compatível será selecionado automaticamente
5. Ajuste o **Control Weight** (0.5–1.0)

**Tipos de ControlNet mais usados:**

| Tipo | Descrição |
|---|---|
| **Canny** | Extrai bordas da imagem guia — preserva contornos |
| **Depth** | Usa mapa de profundidade — preserva estrutura 3D |
| **OpenPose** | Detecta pose corporal — reproduz posições |
| **Scribble** | Usa desenhos simples como guia |
| **SoftEdge** | Bordas suaves, mais flexível que Canny |
| **Lineart** | Para transformar sketches em imagens |

---

### Embeddings / Textual Inversions

**Embeddings** (Textual Inversions) são representações treinadas de conceitos específicos como palavras no vocabulário do modelo. Menores que LoRAs mas úteis para estilos e conceitos pontuais.

**Onde colocar:** `embeddings/` (na raiz do projeto)  
**Extensões:** `.pt` ou `.bin`

**Como usar no prompt:**
```
a portrait in the style of my-embedding-name, detailed, high quality
```

Use o nome exato do arquivo (sem extensão) no prompt.

---

### Hypernetworks

**Hypernetworks** são redes neurais auxiliares que modificam a atenção do modelo durante a geração, alterando o estilo sem mudar o checkpoint. Tecnologia mais antiga, substituída em grande parte pelo LoRA.

**Onde colocar:** `models/hypernetworks/`

**Como usar:** Em **Settings → Stable Diffusion → Hypernetwork**, selecione o arquivo e defina o peso.

---

## Instalando Extensões e Plugins

As extensões adicionam funcionalidades ao WebUI (ADetailer para faces, controlnet adicional, upscalers, etc.).

### Via interface (recomendado)

1. Acesse a aba **Extensions**
2. Clique em **Available** e depois em **Load from**
3. Pesquise pelo nome da extensão
4. Clique em **Install**
5. Após instalar, vá em **Installed** e clique em **Apply and restart UI**

### Via URL do repositório

1. Acesse **Extensions → Install from URL**
2. Cole a URL do repositório Git da extensão
3. Clique em **Install**

### Extensões recomendadas

| Extensão | Descrição |
|---|---|
| **ADetailer** | Melhora automaticamente rostos e mãos na pós-geração |
| **ControlNet** | Controle espacial avançado da geração |
| **Ultimate SD Upscale** | Upscaling em tiles para imagens muito grandes |
| **sd-dynamic-prompts** | Prompts com variações aleatórias e wildcards |
| **Civitai Helper** | Baixa e gerencia modelos diretamente do CivitAI |

> **Atenção:** Extensões são instaladas dentro do container no diretório `extensions/`. Elas persistem enquanto o container existir, mas são perdidas se o container for recriado. Para persistência, mantenha as extensões no volume montado.

---

## Dicas de Prompts

### Estrutura de um bom prompt

```
[sujeito principal], [ação/pose], [ambiente/cenário], [estilo artístico], [qualidade], [iluminação], [câmera/perspectiva]
```

Exemplo:
```
a young woman reading a book, sitting by a window, cozy library, soft natural light, photorealistic, 8k, shallow depth of field, bokeh
```

### Termos de qualidade úteis

```
masterpiece, best quality, highly detailed, sharp focus, 8k uhd, high resolution
```

### Prompt negativo padrão

```
(worst quality, low quality:1.4), blurry, watermark, signature, text, deformed, ugly, bad anatomy, extra limbs, missing limbs, floating limbs, disconnected limbs, mutation, gross proportions
```

### Pesos no prompt

Use parênteses para dar mais ou menos ênfase:
- `(palavra:1.3)` — 30% mais ênfase
- `(palavra:0.7)` — 30% menos ênfase
- `[palavra]` — ligeiramente menos ênfase
- `(palavra)` = `(palavra:1.1)`

Exemplo:
```
a (detailed:1.2) portrait of a woman, (red hair:1.4), [background blur]
```

### BREAK

A keyword `BREAK` separa partes do prompt para evitar que termos se misturem:
```
a fantasy castle on a hill, BREAK dramatic sky with clouds, BREAK photorealistic, 8k
```

### Dicas gerais

- Seja específico: "a golden retriever puppy playing in a park" > "a dog"
- Coloque os termos mais importantes no início do prompt
- Use prompts negativos para evitar artefatos comuns
- Explore diferentes samplers: DPM++ 2M Karras tende a ser rápido e de qualidade
- Para personagens consistentes, combine checkpoint + LoRA + seed fixa
- Comece com 512×512 para testar rapidamente, depois aumente a resolução
