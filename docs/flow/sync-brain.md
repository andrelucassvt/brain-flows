---
generated_at: 2026-07-13
source_commit: 7324bd4
source_state: clean
verified_at: 2026-07-13
status: current
related_plans: []
---

# Flow: Sincronização das skills via `sync-brain.sh`

> **Resumo:** Script standalone que um repositório consumidor executa para baixar as cinco skills do Brain Flows a partir do repositório-fonte e instalá-las em `.claude/skills/`, `.agents/skills/` e `.github/skills/`, atualizando a si mesmo e migrando estruturas antigas no processo.

## Visão Geral

O fluxo começa quando alguém executa `./sync-brain.sh` na raiz de um repositório (tipicamente um repositório diferente do `brain-flows`, que copiou este script para dentro de si — como descrito em `README.md:140-152`). O script clona, com profundidade 1, o repositório-fonte configurado (por padrão `https://github.com/andrelucassvt/brain-flows.git`, branch `main`) para um diretório temporário criado via `mktemp -d`.

Antes de sincronizar qualquer skill, o script verifica se a própria cópia de `sync-brain.sh` está desatualizada em relação à versão do repositório-fonte recém-clonado. Se houver diferença, ele sobrescreve a si mesmo, aplica permissão de execução e reinicia o processo (`exec`) com os mesmos argumentos originais — garantindo que a lógica de sincronização executada seja sempre a mais recente.

Em seguida, para cada uma das cinco skills fixas (`brainstorming`, `flow`, `flow-init`, `writing-plan`, `executing-plan`), o script confirma que existe um `SKILL.md` na origem, copia o conteúdo para uma área de staging local e, por fim, espelha essa staging para os três diretórios de destino (`.claude/skills/`, `.agents/skills/`, `.github/skills/`) usando `rsync --delete`, o que remove qualquer arquivo obsoleto que não exista mais na origem.

Por último, e de forma independente da sincronização, o script verifica se existem diretórios legados `plan/` ou `flow/` na raiz do repositório onde está sendo executado. Se existirem, move o conteúdo para `docs/plan/` e `docs/flow/` respectivamente e remove o diretório antigo — uma migração de estrutura que roda a cada execução, mas só tem efeito quando os diretórios antigos ainda existem.

## Passo a Passo

1. **Configuração inicial** — `sync-brain.sh:9-21`
   `set -euo pipefail` ativa modo estrito; são resolvidos `SCRIPT_DIR`/`SCRIPT_NAME`, e definidas (com defaults sobrescrevíveis por variável de ambiente) `SOURCE_REPO`, `SOURCE_BRANCH`, `SOURCE_SKILLS_PATH`, a lista fixa `BRAIN_SKILLS` e os três `TARGET_SKILLS_DIRS`.
2. **Preparação de diretórios temporários** — `sync-brain.sh:23-30`
   Cria `TMP_DIR` via `mktemp -d` com subpastas `source/` e `skills/` (staging), e registra `cleanup()` via `trap ... EXIT` para remover tudo ao final.
3. **Clone do repositório-fonte** — `sync-brain.sh:32-33`
   `git clone --depth 1 --branch "$SOURCE_BRANCH" "$SOURCE_REPO" "$SOURCE_DIR" --quiet` baixa apenas o branch configurado, sem histórico.
4. **Auto-atualização do script** — `sync-brain.sh:35-46`
   Compara (`diff -q`) o `sync-brain.sh` recém-clonado com o script local. Se diferentes: copia a nova versão por cima da local, aplica `chmod +x`, chama `cleanup()` manualmente, remove o trap (`trap - EXIT`) e reexecuta o script atualizado via `exec "$SCRIPT_DIR/$SCRIPT_NAME" "$@"`, repassando os argumentos originais.
5. **Preparação da staging por skill** — `sync-brain.sh:49-61`
   Para cada nome em `BRAIN_SKILLS`, verifica se `$SOURCE_DIR/$SOURCE_SKILLS_PATH/<skill>/SKILL.md` existe; se não, imprime erro e encerra com `exit 1`. Caso exista, faz `rsync -a --delete` da pasta da skill na origem para a staging local.
6. **Distribuição para os destinos locais** — `sync-brain.sh:63-73`
   Para cada diretório em `TARGET_SKILLS_DIRS` (`.claude/skills`, `.agents/skills`, `.github/skills`), cria a pasta se necessário e, para cada skill, faz `rsync -a --delete` da staging para o destino final, espelhando o conteúdo exatamente.
7. **Migração de estrutura legada** — `sync-brain.sh:77-93`
   A função `migrate_root_dir_to_docs` é chamada para `"plan"` e depois `"flow"`: se `./plan` ou `./flow` existir na raiz do repositório, move o conteúdo para `./docs/plan` ou `./docs/flow` via `rsync -a` e remove o diretório antigo com `rm -rf`.

### Caminhos alternativos

- **Skill ausente na origem:** `sync-brain.sh:53-56` — se `SKILL.md` não existir para alguma skill esperada, o script imprime `❌ Skill ausente no repositório-fonte: ...` em stderr e encerra imediatamente com código 1, sem tocar nos diretórios de destino.
- **Script já atualizado:** `sync-brain.sh:38` — se o `diff -q` não encontrar diferença, o bloco de auto-atualização é pulado silenciosamente e a execução segue normalmente.
- **Diretórios `plan/`/`flow/` inexistentes:** `sync-brain.sh:82` — a migração é um no-op quando os diretórios antigos não existem; nenhuma mensagem é impressa para essa skill de migração.
- **Falha no clone (rede/branch/repo inválido):** não há tratamento explícito; como `set -euo pipefail` está ativo, qualquer falha do `git clone` (linha 33) interrompe o script e aciona o `trap cleanup` antes de sair.

## Arquivos Envolvidos

| Camada | Arquivo | Responsabilidade |
|--------|---------|------------------|
| Script principal | `sync-brain.sh` | Único arquivo do fluxo: orquestra clone, auto-atualização, sincronização de skills e migração de diretórios legados |
| Origem (remota) | `plugins/brain-flows/skills/<skill>/SKILL.md` (no repositório-fonte) | Conteúdo canônico de cada skill que será copiado; sua ausência interrompe o fluxo |
| Destino local | `.claude/skills/<skill>/`, `.agents/skills/<skill>/`, `.github/skills/<skill>/` | Cópias espelhadas das skills, mantidas em sincronia via `rsync --delete` |
| Documentação | `README.md:140-152` | Descreve o uso esperado do script e das variáveis de ambiente que o parametrizam |

## Regras de Negócio Relevantes

- **Lista fixa de skills sincronizadas** — `sync-brain.sh:16`: apenas `brainstorming`, `flow`, `flow-init`, `writing-plan`, `executing-plan` são copiadas, mesmo que o repositório-fonte tenha outras pastas em `SOURCE_SKILLS_PATH`.
- **`SKILL.md` obrigatório** — `sync-brain.sh:53-56`: uma skill sem `SKILL.md` na origem é tratada como erro fatal, interrompendo toda a sincronização (nenhuma skill é aplicada aos destinos após esse ponto).
- **Espelhamento exato via `--delete`** — `sync-brain.sh:59,69`: o `rsync --delete` garante que arquivos removidos na origem também sejam removidos nos destinos, não apenas que novos arquivos sejam adicionados.
- **Auto-atualização com reexecução** — `sync-brain.sh:38-45`: o script pode substituir a si mesmo em disco e reiniciar sua própria execução (`exec`) antes de sincronizar qualquer skill, garantindo que a versão executada seja sempre a mais recente disponível na origem.
- **Migração idempotente de diretórios legados** — `sync-brain.sh:77-93`: `plan/` e `flow/` na raiz são migrados para `docs/plan/` e `docs/flow/` a cada execução, mas só produzem efeito enquanto o diretório antigo ainda existir.

## Dependências Externas

- **Git** — usado para clonar o repositório-fonte (`sync-brain.sh:33`); requer acesso de rede ao host configurado em `SOURCE_REPO` (GitHub por padrão).
- **rsync** — usado para copiar e espelhar diretórios (staging e destinos finais).
- **mktemp** — usado para criar o diretório temporário de trabalho.
- **Variáveis de ambiente configuráveis:** `SOURCE_REPO`, `SOURCE_BRANCH`, `SOURCE_SKILLS_PATH` (`sync-brain.sh:13-15`), permitindo apontar para forks ou branches alternativos sem editar o script.

## Observações

- O script pressupõe que é executado a partir da raiz do repositório onde as skills devem ser instaladas — `SCRIPT_DIR` é derivado do próprio caminho do script (`sync-brain.sh:11`), então rodá-lo de um local diferente da raiz do projeto consumidor produziria diretórios de destino no lugar errado.
- Não há tratamento de erro específico para falha de rede durante o `git clone` (linha 33) além do `set -e` padrão; a mensagem de erro exibida ao usuário será a do próprio `git`, não uma mensagem customizada do script.
- O contrapartida deste fluxo é `package-brain.sh`, citado em `README.md:154-158`, que reconstrói `plugins/brain-flows/skills/` a partir de `.claude/skills/` — não foi mapeado neste documento por estar fora do escopo do fluxo de sincronização.
- Neste repositório (`brain-flows`), o próprio `sync-brain.sh` na raiz aponta, por padrão, para este mesmo repositório como `SOURCE_REPO` — rodá-lo aqui sincronizaria as skills consigo mesmas (dogfooding), e não instalaria um conjunto de skills externo.
