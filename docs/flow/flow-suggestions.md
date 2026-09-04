---
generated_at: 2026-07-22
source_commit: 5c5a035
source_state: dirty
verified_at: 2026-09-03
status: current
related_plans: [docs/plan/brain-flows-2-0-0.md]
---

# Sugestões de Flows a Documentar

> Gerado em 2026-07-22. Invoque a skill `flow` para criar qualquer um destes flows.
> Observação: cada skill já é autodescrita em seu próprio `SKILL.md`, então um flow completo só agrega valor se o processo interno da skill for depurado ou estendido.

## Flows Sugeridos

### Skill `flow-init`
**Arquivo a criar:** `docs/flow/flow-init.md`
**Resumo:** Documenta como a skill varre o repositório, gera `docs/flow/project-structure.md`, delega flows de features em paralelo quando possível (com fallback sequencial), decide entre flows completos ou sugestões e atualiza `AGENTS.md`/`CLAUDE.md` pelo guia.

---

### Skill `flow`
**Arquivo a criar:** `docs/flow/flow.md`
**Resumo:** Documenta como a skill rastreia uma feature do ponto de entrada à camada de dados, podendo delegar a varredura a subagente somente-leitura com fallback direto, e produz `docs/flow/<nome>.md` com ordem, arquivos e regras de negócio.

---

### Skill `brainstorming`
**Arquivo a criar:** `docs/flow/brainstorming.md`
**Resumo:** Documenta o processo de esclarecer o objetivo, ler flows relacionados, comparar alternativas, auditar o design com rubrica compacta e emitir o bloco de handoff após aprovação.

---

### Skill `writing-plan`
**Arquivo a criar:** `docs/flow/writing-plan.md`
**Resumo:** Documenta como o handoff do brainstorming vira um plano acionável em `docs/plan/`, escolhendo Template curto para até 2 fases ou formato completo/multi-parte, com Design de Origem, checkboxes e verificações.

---

### Skill `executing-plan`
**Arquivo a criar:** `docs/flow/executing-plan.md`
**Resumo:** Documenta como o plano é revisado contra o repositório, executado uma tarefa por vez, com revisor independente para Logic ou 3+ fases quando possível, fallback direto e atualização dos flows afetados.

---

### Script `package-brain.sh`
**Arquivo a criar:** `docs/flow/package-brain.md`
**Resumo:** Documenta o empacotamento das cinco skills de `.claude/skills/` para `plugins/brain-flows/skills/` via staging e `rsync --delete` — contrapartida do fluxo já documentado em `sync-brain.md`.

## Já documentados

- `docs/flow/project-structure.md` — Estrutura geral do projeto
- `docs/flow/sync-brain.md` — Sincronização das skills via `sync-brain.sh`
</content>
