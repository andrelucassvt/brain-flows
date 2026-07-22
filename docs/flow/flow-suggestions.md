---
generated_at: 2026-07-22
source_commit: 3864c0e
source_state: clean
verified_at: 2026-07-22
status: current
related_plans: []
---

# Sugestões de Flows a Documentar

> Gerado em 2026-07-22. Invoque a skill `flow` para criar qualquer um destes flows.
> Observação: cada skill já é autodescrita em seu próprio `SKILL.md`, então um flow completo só agrega valor se o processo interno da skill for depurado ou estendido.

## Flows Sugeridos

### Skill `flow-init`
**Arquivo a criar:** `docs/flow/flow-init.md`
**Resumo:** Documenta como a skill varre o repositório, gera `docs/flow/project-structure.md`, decide entre flows completos ou sugestões e reescreve `AGENTS.md`/`CLAUDE.md` a partir do guia em `references/guide-project-instructions.md`.

---

### Skill `flow`
**Arquivo a criar:** `docs/flow/flow.md`
**Resumo:** Documenta como a skill rastreia uma feature do ponto de entrada à camada de dados e produz um `docs/flow/<nome>.md` com ordem de execução, arquivos e regras de negócio.

---

### Skill `brainstorming`
**Arquivo a criar:** `docs/flow/brainstorming.md`
**Resumo:** Documenta o processo de esclarecer o objetivo, ler flows relacionados, comparar alternativas e emitir o bloco de handoff após aprovação do design.

---

### Skill `writing-plan`
**Arquivo a criar:** `docs/flow/writing-plan.md`
**Resumo:** Documenta como o handoff do brainstorming vira um plano acionável em `docs/plan/`, com Design de Origem, fases, checkboxes, verificações e rollback.

---

### Skill `executing-plan`
**Arquivo a criar:** `docs/flow/executing-plan.md`
**Resumo:** Documenta como o plano é revisado contra o repositório, executado uma tarefa por vez, com o Design de Origem como limite para drift e atualização dos flows afetados.

---

### Script `package-brain.sh`
**Arquivo a criar:** `docs/flow/package-brain.md`
**Resumo:** Documenta o empacotamento das cinco skills de `.claude/skills/` para `plugins/brain-flows/skills/` via staging e `rsync --delete` — contrapartida do fluxo já documentado em `sync-brain.md`.

## Já documentados

- `docs/flow/project-structure.md` — Estrutura geral do projeto
- `docs/flow/sync-brain.md` — Sincronização das skills via `sync-brain.sh`
</content>
