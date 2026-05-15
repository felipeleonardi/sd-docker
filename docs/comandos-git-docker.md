# Comandos Essenciais de Git e Docker

Referência rápida dos comandos mais usados no dia a dia deste projeto. Para instalação das ferramentas, consulte [instalacao-git-docker.md](instalacao-git-docker.md).

---

## Git

### Configuração inicial (uma vez por máquina)

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

### Clonar o repositório

```bash
git clone https://github.com/felipeleonardi/sd-docker.git
cd sd-docker
```

### Ver o estado atual

```bash
git status              # arquivos modificados, staged e não rastreados
git diff                # diferenças ainda não adicionadas ao stage
git diff --staged       # diferenças já no stage (a serem commitadas)
git log --oneline -10   # últimos 10 commits resumidos
```

### Salvar alterações

```bash
git add arquivo.txt          # adicionar arquivo específico ao stage
git add .                    # adicionar tudo (cuidado com arquivos indesejados)
git commit -m "mensagem"     # criar commit com mensagem
```

Boas práticas para mensagens de commit:

```
feat: adiciona suporte a LoRA XL
fix: corrige erro de permissão no entrypoint
docs: atualiza instruções de ControlNet
chore: adiciona models/diffusers ao gitignore
```

### Sincronizar com o repositório remoto

```bash
git pull                     # baixar e aplicar commits do remote
git push                     # enviar commits locais para o remote
git push origin nome-branch  # enviar branch específica
```

### Trabalhar com branches

```bash
git branch                        # listar branches locais
git checkout -b minha-feature     # criar e mudar para nova branch
git checkout main                 # voltar para a main
git merge minha-feature           # mesclar branch na atual
git branch -d minha-feature       # deletar branch após merge
```

### Desfazer alterações

```bash
git restore arquivo.txt      # descartar alterações não commitadas em um arquivo
git restore .                # descartar todas as alterações não commitadas
git reset HEAD~1             # desfazer o último commit (mantém as alterações nos arquivos)
```

> **Atenção:** `git restore .` e `git reset --hard` descartam trabalho permanentemente. Use com cuidado.

---

## Docker

### Ver o estado dos containers

```bash
docker ps                    # containers em execução
docker ps -a                 # todos os containers (incluindo parados)
docker images                # imagens locais disponíveis
```

### Gerenciar containers com Docker Compose

```bash
docker compose up --build    # build da imagem e inicia o container (primeiro uso)
docker compose up -d         # inicia em background (sem rebuild)
docker compose down          # para e remove o container
docker compose restart       # reinicia o container
```

### Ver logs

```bash
docker compose logs forge         # logs do serviço (snapshot)
docker compose logs -f forge      # logs em tempo real (Ctrl+C para sair)
docker compose logs --tail=50 forge  # últimas 50 linhas
```

### Executar comandos dentro do container

```bash
docker exec -it sd-forge bash         # abrir shell interativo no container
docker exec sd-forge nvidia-smi       # checar GPU dentro do container
```

### Build e limpeza

```bash
docker compose build --no-cache   # rebuild da imagem sem usar cache
docker system prune               # remove containers parados, imagens e redes não usadas
docker volume prune               # remove volumes não usados (cuidado: pode apagar dados)
docker image prune -a             # remove todas as imagens não usadas por containers
```

### Monitoramento

```bash
docker stats                     # uso de CPU, memória e rede em tempo real
watch -n 1 nvidia-smi            # uso de GPU atualizado a cada segundo
```

---

## Usando `sd.sh` (atalho para este projeto)

O script `sd.sh` encapsula os comandos mais comuns do Docker Compose:

```bash
./sd.sh start     # inicia o Docker e o container (com build se necessário)
./sd.sh stop      # para o container
./sd.sh rebuild   # rebuild completo da imagem e reinicia
```

Para uso manual sem o script, os equivalentes são:

| `sd.sh`          | Equivalente Docker                                    |
|---|---|
| `./sd.sh start`  | `docker compose up -d --build`                        |
| `./sd.sh stop`   | `docker compose down`                                 |
| `./sd.sh rebuild`| `docker compose down && docker compose build --no-cache && docker compose up -d` |
