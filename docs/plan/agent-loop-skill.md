# Skill `agent-loop`

> **Objetivo:** Adicionar uma 6ª skill `agent-loop` que orquestra a cadeia `brainstorming → writing-plan → executing-plan` em sequência automática, sem pausar entre `writing-plan` e `executing-plan`, mantendo a aprovação do design (Fase 5 do brainstorming) como único checkpoint humano.
> **Design de origem:** brainstorming desta conversa
> **Flows relacionados:** `docs/flow/project-structure.md`

## Contexto

Hoje a cadeia tem dois pontos de pausa: a aprovação do design no `brainstorming` e a pergunta "quer ajustar antes de executar?" ao final do `writing-plan`. O usuário quer poder pedir explicitamente um modo onde, depois de aprovar o design, o restante roda sem essa segunda pausa — mas só quando pedido, sem custo para o uso normal das três skills existentes.

## Design de Origem

- **Decisão aprovada:** Criar uma skill nova e isolada `agent-loop` que atua como orquestrador fino da cadeia existente, sem editar `brainstorming`, `writing-plan` ou `executing-plan`. Ela invoca as três skills na ordem normal, respeita o gate de aprovação do design, e pula apenas a pergunta final do `writing-plan`, invocando `executing-plan` diretamente. Os bloqueios de segurança nativos do `executing-plan` (drift contra o Design de Origem, falta de autoridade/dependência externa) continuam intactos.
- **Alternativas descartadas:**
  - Campo "Modo de execução" no Handoff do brainstorming, propagado via writing-plan — descartada por exigir editar as 3 skills existentes e embutir lógica de detecção que roda em toda invocação de `brainstorming` (custo de token constante mesmo sem uso do loop), contra a recomendação de manter o workflow simples por padrão.
  - Convenção via `AGENTS.md`/`CLAUDE.md` do projeto-alvo — descartada por ser configuração global e silenciosa, fora do padrão de decisão por pedido que a cadeia já usa.
- **Tipo de mudança:** Logic (skill nova de orquestração; sem stack de aplicação, então "verificação" é validação de plugin + evals de acionamento, não testes unitários).

## Arquitetura / Escopo

| Arquivo | Ação | Responsabilidade |
|---------|------|-----------------|
| `.claude/skills/agent-loop/SKILL.md` | criar | Definição da skill: frontmatter (`name`, `description` com gatilhos explícitos) e fluxo de orquestração |
| `.claude/skills/agent-loop/evals/evals.json` | criar | Testes de acionamento positivo/negativo, no padrão das outras 5 skills |
| `.agents/skills/agent-loop/` | criar | Espelho idêntico de `.claude/skills/agent-loop/` |
| `.github/skills/agent-loop/` | criar | Espelho idêntico de `.claude/skills/agent-loop/` |
| `plugins/brain-flows/skills/agent-loop/` | criar (via `package-brain.sh`) | Fonte canônica distribuível do plugin |
| `sync-brain.sh` | editar | Adicionar `agent-loop` ao array `BRAIN_SKILLS` |
| `package-brain.sh` | editar | Adicionar `agent-loop` ao array `BRAIN_SKILLS` |
| `plugins/brain-flows/.claude-plugin/plugin.json` | editar | Bump de `version` (1.1.0 → 1.2.0) |
| `plugins/brain-flows/.codex-plugin/plugin.json` | editar | Mesma versão do manifesto Claude |
| `CHANGELOG.md` | editar | Registrar a nova skill na versão 1.2.0 |
| `submission/evals.json` | editar | Adicionar 1 teste positivo e 1 negativo para `agent-loop` |
| `docs/flow/project-structure.md` | editar | Atualizar diagrama da cadeia e tabela de Features com a nova skill |
| `README.md` | editar | Mencionar a skill `agent-loop` na lista de skills e no comando de instalação |

## Fases

### Fase 1 — Criar a skill `agent-loop`

- [x] Passo 1: Criar `.claude/skills/agent-loop/SKILL.md` com frontmatter `name: agent-loop` e `description` cobrindo gatilhos explícitos ("modo agente autônomo", "rode o fluxo inteiro sem parar", "agent loop", "brainstorme, planeje e implemente sem pausar depois de eu aprovar") e negando acionamento implícito (não ativar sem pedido explícito de autonomia).
- [x] Passo 2: Escrever o fluxo de orquestração no corpo da skill: (1) invocar `brainstorming` normalmente; (2) parar no gate de aprovação da Fase 5 — único checkpoint humano obrigatório, nunca pular; (3) após aprovação, invocar `writing-plan` com o Handoff; (4) ao `writing-plan` salvar o plano, pular a pergunta "quer ajustar antes de executar?" e invocar `executing-plan` na mesma resposta; (5) deixar os bloqueios nativos do `executing-plan` (drift contra Design de Origem, falta de autoridade/dependência externa) interromperem normalmente sem serem suprimidos; (6) entregar o resumo final de conclusão do `executing-plan` como de costume.
- [x] Passo 3: Adicionar seção "Regras gerais" deixando explícito que a skill não duplica nem reimplementa a lógica das três skills existentes — apenas orquestra a ordem de invocação e informa qual pausa pular — e que o usuário pode interromper o loop a qualquer momento.
- [x] Passo 4: Criar `.claude/skills/agent-loop/evals/evals.json` seguindo o formato de `.claude/skills/brainstorming/evals/evals.json`, com: 1 eval positivo (pedido explícito de modo autônomo fim-a-fim, cobrindo os assertions "invokes_brainstorming_first", "stops_for_design_approval", "auto_chains_writing_plan_and_executing_plan", "does_not_suppress_executing_plan_safety_stops"); 1 eval negativo (pedido normal de brainstorming/plano, sem menção a loop/autônomo, cobrindo o assertion "does_not_trigger_without_explicit_autonomy_request").
- [x] Verificação: `test -f .claude/skills/agent-loop/SKILL.md && test -f .claude/skills/agent-loop/evals/evals.json`; `python3 -m json.tool .claude/skills/agent-loop/evals/evals.json` sem erro de sintaxe. — OK, ambos os arquivos existem e o JSON é válido.

### Fase 2 — Propagar aos espelhos e à fonte canônica

- [x] Passo 1: Copiar `.claude/skills/agent-loop/` para `.agents/skills/agent-loop/` e `.github/skills/agent-loop/` (cópia idêntica, sem adaptação de plataforma).
- [x] Passo 2: Adicionar `agent-loop` ao array `BRAIN_SKILLS` em `sync-brain.sh`.
- [x] Passo 3: Adicionar `agent-loop` ao array `BRAIN_SKILLS` em `package-brain.sh`, na mesma posição/ordem usada no passo anterior.
- [x] Passo 4: Rodar `./package-brain.sh` para reconstruir `plugins/brain-flows/skills/` a partir de `.claude/skills/`, gerando `plugins/brain-flows/skills/agent-loop/`. (`rsync` não estava instalado no ambiente; instalado via `apt-get install rsync` antes de rodar o script.)
- [x] Verificação: `diff -rq .claude/skills/agent-loop .agents/skills/agent-loop`, `diff -rq .claude/skills/agent-loop .github/skills/agent-loop` e `diff -rq .claude/skills/agent-loop plugins/brain-flows/skills/agent-loop` — sem diferenças (ALL IDENTICAL).

### Fase 3 — Manifestos, changelog e evals de submissão

- [x] Passo 1: Atualizar `version` para `1.2.0` em `plugins/brain-flows/.claude-plugin/plugin.json` e em `plugins/brain-flows/.codex-plugin/plugin.json` (mesma versão nos dois).
- [x] Passo 2: Adicionar entrada `## 1.2.0 — 2026-07-22` no topo de `CHANGELOG.md` descrevendo a nova skill `agent-loop` e seu propósito (orquestração automática opcional da cadeia existente, sem alterar as outras 5 skills).
- [x] Passo 3: Adicionar em `submission/evals.json` um teste `positive-agent-loop` (pedido explícito de modo autônomo fim-a-fim) e um teste `negative-agent-loop-not-requested` (pedido comum de brainstorming/plano sem menção a autonomia, que não deve acionar `agent-loop`), seguindo o formato dos testes existentes no arquivo.
- [x] Verificação: `python3 -m json.tool` nos três JSONs sem erro; `grep '"version"'` mostrando `1.2.0` nos dois `plugin.json`. — Confirmado.

### Fase 4 — Atualizar documentação e flows afetados

- [x] Passo 1: Em `docs/flow/project-structure.md`, atualizar o diagrama "Cadeia de skills" (seção Arquitetura) para incluir `agent-loop` como orquestrador opcional sobre a cadeia existente, e adicionar uma linha na tabela "Features" descrevendo a skill.
- [x] Passo 2: Atualizar o frontmatter de `docs/flow/project-structure.md` (`source_commit`, `related_plans`) para refletir a revisão. (`generated_at`/`verified_at` mantidos em 2026-07-22, mesma data da revisão.)
- [x] Passo 3: Em `README.md`, adicionar `agent-loop` à lista de skills (nova seção "Optional: run the whole cycle unattended", tabela "Which skill should I use?" e lista de invocação), sem reescrever as seções existentes das outras 5 skills.
- [x] Verificação: `grep -q "agent-loop" docs/flow/project-structure.md README.md` — confirmado ("mentions confirmed").

### Fase 5 — Validação final

- [x] Passo 1: Rodar `claude plugin validate .` e `claude plugin validate ./plugins/brain-flows` — ambos com "Validation passed".
- [x] Passo 2: Conferir que os quatro diretórios de skills (`.claude/skills`, `.agents/skills`, `.github/skills`, `plugins/brain-flows/skills`) têm exatamente 6 skills cada e são idênticos entre si.
- [x] Verificação: `for d in .claude/skills .agents/skills .github/skills plugins/brain-flows/skills; do ls "$d"; done` — as mesmas 6 pastas em todos os 4 diretórios.

## Critérios de Sucesso

- [x] Skill `agent-loop` criada e idêntica nos 4 diretórios de distribuição
- [x] `sync-brain.sh` e `package-brain.sh` reconhecem `agent-loop` em `BRAIN_SKILLS`
- [x] Manifestos com versão `1.2.0` sincronizada e `CHANGELOG.md` atualizado
- [x] `submission/evals.json` e `evals/evals.json` da nova skill com casos positivo e negativo
- [x] `docs/flow/project-structure.md` e `README.md` mencionam a nova skill
- [x] `brainstorming`, `writing-plan` e `executing-plan` permanecem byte-a-byte inalterados
- [ ] _(manual — feito pelo usuário)_ Testar a skill `agent-loop` em uma conversa real pedindo o modo autônomo

## Riscos e Mitigações

| Risco | Probabilidade | Mitigação |
|-------|--------------|-----------|
| `agent-loop` acionar implicitamente em pedidos normais, pulando o gate de aprovação sem o usuário pedir | Média | `description` da skill exige gatilho explícito de autonomia; eval negativo cobre pedido comum sem essa menção |
| Divergência entre os 4 diretórios de skills após cópia manual | Baixa | Verificação da Fase 2 usa `diff -rq` nos quatro pares |
| `claude plugin validate` indisponível neste ambiente de execução | Média | Registrar como validação pendente para o usuário, sem bloquear a entrega |

## Rollback

Reverter o commit que adiciona a skill: remover `.claude/skills/agent-loop/`, `.agents/skills/agent-loop/`, `.github/skills/agent-loop/`, `plugins/brain-flows/skills/agent-loop/`, remover `agent-loop` de `BRAIN_SKILLS` em ambos os scripts, reverter a versão dos `plugin.json` para `1.1.0`, remover a entrada do `CHANGELOG.md` e os testes adicionados em `submission/evals.json`.

## Adendo — 2026-07-24: remoção total das pausas de aprovação

Pedido de seguimento do usuário: `agent-loop` não deveria manter nenhuma pausa de aprovação humana, nem mesmo a aprovação do design da Fase 5 do `brainstorming` — o próprio agente deve escolher a melhor alternativa e seguir implementando até concluir, sem parar em nenhum ponto (a exceção sendo prompts de permissão de ferramenta impostos pelo ambiente do usuário, que estão fora do alcance de qualquer skill em Markdown).

Mudanças aplicadas sobre o que este plano já havia entregue, mantendo o mesmo escopo (só `agent-loop` e seus artefatos de distribuição/documentação; `brainstorming`, `writing-plan` e `executing-plan` seguem intocados):

- `SKILL.md` da `agent-loop` reescrito: a Fase 5 do `brainstorming` deixa de pedir aprovação — o agente escolhe a alternativa recomendada, documenta o motivo, e segue direto por `writing-plan` e `executing-plan` sem nenhuma pausa. Limites reais de capacidade (credencial ausente, dependência externa impossível) passam a ser contornados com a decisão mais razoável e relatados no resumo final, em vez de interromper o fluxo.
- `evals/evals.json` da skill reescrito: eval positivo agora cobre autonomia total sem aprovação alguma; novo eval negativo cobre o caso de o usuário querer manter a aprovação do design e só pular a pausa entre plano e execução (isso não aciona mais `agent-loop`).
- `submission/evals.json`: prompt/expected_behavior do teste `positive-agent-loop` atualizados para o novo comportamento.
- Versão dos dois `plugin.json` bump para `1.3.0`; nova entrada no `CHANGELOG.md`.
- `docs/flow/project-structure.md` e `README.md` atualizados para descrever o orquestrador sem nenhum gate humano.
- Verificações repetidas: `package-brain.sh` rodado novamente, `diff -rq` confirmando os 4 diretórios idênticos, `claude plugin validate .` e `claude plugin validate ./plugins/brain-flows` passando, `python3 -m json.tool` em todos os JSONs tocados, e `git diff --stat` confirmando que `brainstorming`/`writing-plan`/`executing-plan` seguem sem alteração nos 4 diretórios.
