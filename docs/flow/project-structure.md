---
generated_at: 2026-07-22
source_commit: ee719d4
source_state: clean
verified_at: 2026-07-24
status: current
related_plans: [docs/plan/agent-loop-skill.md]
---

# Estrutura do Projeto: Brain Flows

> **Resumo:** Marketplace/plugin de skills para desenvolvimento orientado por documentação. Não é um app: é uma coleção de cinco skills em Markdown (`SKILL.md`), manifestos de plugin para Claude Code e Codex, e scripts Bash que sincronizam e empacotam essas skills entre os diretórios de distribuição.

## Stack e Tecnologias

| Elemento | Valor |
|----------|-------|
| Formato das skills | Markdown com frontmatter (`SKILL.md`: `name` + `description`) |
| Scripts de automação | Bash (`sync-brain.sh`, `package-brain.sh`), `set -euo pipefail` |
| Manifestos | JSON (`marketplace.json`, `plugin.json` para Claude e Codex) |
| Gerenciador de pacotes | Nenhum — sem manifesto de dependências de linguagem |
| Ferramentas externas | `git`, `rsync`, `mktemp` |
| Plataformas-alvo | Claude Code e Codex |

## Arquitetura

O projeto tem uma única fonte canônica de skills em `plugins/brain-flows/skills/` e três diretórios espelhados por plataforma (`.claude/skills/`, `.agents/skills/`, `.github/skills/`). O `package-brain.sh` reconstrói a pasta canônica do plugin a partir de `.claude/skills/`; o `sync-brain.sh` faz o caminho inverso, baixando as skills do repositório-fonte remoto e distribuindo-as para os três destinos locais. As cinco skills principais formam um workflow encadeado por *handoffs* explícitos, e cada uma produz documentos Markdown em `docs/` como memória compartilhada do processo. Uma sexta skill, `agent-loop`, é um orquestrador opcional sobre essa mesma cadeia: acionada só por pedido explícito de autonomia total, ela invoca as três skills de mudança na ordem normal, mas sem nenhuma pausa de aprovação humana — inclusive a escolha do design fica a cargo do próprio agente, que decide a alternativa recomendada e segue direto até concluir.

```
Cadeia de skills (workflow):
flow-init ─> flow ─> brainstorming ─> writing-plan ─> executing-plan
              │                            (handoff / design de origem)
              └─> docs/flow/*.md          docs/plan/*.md

agent-loop (opcional, sob pedido explícito de autonomia total):
  orquestra brainstorming ─> writing-plan ─> executing-plan
  sem nenhuma pausa de aprovação — o agente escolhe o design sozinho

Distribuição das skills:
.claude/skills/ ──package-brain.sh──> plugins/brain-flows/skills/ (canônico)
repositório-fonte ──sync-brain.sh──> .claude/skills/ + .agents/skills/ + .github/skills/
```

### Regras de dependência

- A fonte canônica para empacotamento é `.claude/skills/` (`package-brain.sh:8`); os três diretórios de destino devem ser mantidos idênticos entre si.
- Seis skills fixas são sincronizadas/empacotadas: `agent-loop`, `brainstorming`, `flow`, `flow-init`, `writing-plan`, `executing-plan` (`sync-brain.sh:16`, `package-brain.sh:9`).

## Features

Neste projeto, cada "feature" é uma skill do workflow ou um script de distribuição.

| Feature | Caminho principal | Descrição resumida |
|---------|------------------|-------------------|
| Skill `flow-init` | `plugins/brain-flows/skills/flow-init/` | Varre o projeto inteiro e inicializa `docs/flow/` com a estrutura geral e flows opcionais; possui `references/guide-project-instructions.md` |
| Skill `flow` | `plugins/brain-flows/skills/flow/` | Mapeia uma feature de ponta a ponta e gera `docs/flow/<nome>.md` |
| Skill `brainstorming` | `plugins/brain-flows/skills/brainstorming/` | Explora o design antes de implementar e emite bloco de handoff após aprovação |
| Skill `writing-plan` | `plugins/brain-flows/skills/writing-plan/` | Converte o design aprovado em plano acionável em `docs/plan/` |
| Skill `executing-plan` | `plugins/brain-flows/skills/executing-plan/` | Executa o plano uma tarefa por vez e atualiza os flows afetados |
| Skill `agent-loop` | `plugins/brain-flows/skills/agent-loop/` | Orquestra `brainstorming → writing-plan → executing-plan` sem nenhuma pausa de aprovação humana, inclusive escolhendo o design sozinha; só ativa por pedido explícito de autonomia total |
| Sincronização | `sync-brain.sh` | Baixa as skills do repositório-fonte e distribui para os três destinos locais (ver `docs/flow/sync-brain.md`) |
| Empacotamento | `package-brain.sh` | Reconstrói `plugins/brain-flows/skills/` a partir de `.claude/skills/` |

## Camadas / Módulos Compartilhados

| Tipo | Caminho | Responsabilidade |
|------|---------|-----------------|
| Skills canônicas | `plugins/brain-flows/skills/` | Fonte distribuível das cinco skills, empacotada no plugin |
| Espelhos por plataforma | `.claude/skills/`, `.agents/skills/`, `.github/skills/` | Cópias idênticas das skills mantidas em sincronia via `rsync --delete` |
| Documentação de processo | `docs/flow/` | Estrutura do projeto e flows individuais (memória compartilhada) |
| Guia de referência | `plugins/brain-flows/skills/flow-init/references/guide-project-instructions.md` | Boas práticas para gerar `AGENTS.md`/`CLAUDE.md` |
| Evals | `submission/evals.json` e `<skill>/evals/evals.json` | Testes positivos/negativos de acionamento das skills |
| Assets | `docs/assets/` | Imagens do workflow usadas no `README.md` |

## Configuração

| Componente | Arquivo | Responsabilidade |
|-----------|---------|-----------------|
| Manifesto do marketplace (Claude) | `.claude-plugin/marketplace.json` | Declara o marketplace `brain-flows` e o plugin apontando para `./plugins/brain-flows` |
| Manifesto do marketplace (Codex/agents) | `.agents/plugins/marketplace.json` | Equivalente para a plataforma Codex |
| Manifesto do plugin (Claude) | `plugins/brain-flows/.claude-plugin/plugin.json` | Nome, versão `1.1.0`, autor, licença |
| Manifesto do plugin (Codex) | `plugins/brain-flows/.codex-plugin/plugin.json` | Metadados de interface, categoria e `defaultPrompt` |
| Distribuição — sync | `sync-brain.sh` | Variáveis `SOURCE_REPO`, `SOURCE_BRANCH`, `SOURCE_SKILLS_PATH` sobrescrevíveis por ambiente |
| Distribuição — package | `package-brain.sh` | Empacota as skills locais na pasta do plugin |

## Dependências Externas Principais

Sem manifesto de dependências de linguagem. As dependências são ferramentas de linha de comando:

| Ferramenta | Uso no projeto |
|--------|---------------|
| `git` | Clona o repositório-fonte no `sync-brain.sh:33` |
| `rsync` | Espelha diretórios de skills (`--delete`) em ambos os scripts |
| `mktemp` | Cria diretórios temporários de trabalho e staging |

## Observações

- O `sync-brain.sh` na raiz deste repositório aponta, por padrão, para o próprio `brain-flows` como `SOURCE_REPO` — executá-lo aqui sincroniza as skills consigo mesmas (dogfooding), conforme detalhado em `docs/flow/sync-brain.md:77`.
- Não existiam `AGENTS.md` nem `CLAUDE.md` na raiz antes desta execução; foram criados por esta skill.
- O `.gitignore` ignora `.DS_Store` e `.sync-brain.sh` (note o ponto inicial — não é o `sync-brain.sh` versionado).
- Antes de um release, o guia (`README.md:165`) instrui a manter a mesma versão nos dois `plugin.json`, rodar os validadores de plataforma e registrar a mudança no `CHANGELOG.md`.
</content>
</invoke>
