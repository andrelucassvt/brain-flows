# Changelog

Todas as mudanças relevantes deste projeto serão registradas aqui.

## 1.1.0 — 2026-07-14

- Contrato de handoff explícito entre `brainstorming`, `writing-plan` e `executing-plan`: cada skill ganhou seções **Entrada esperada** e **Saída (Handoff)**, tornando a cadeia legível ponta a ponta.
- `brainstorming` passa a emitir um bloco **Handoff para o Plano** após a aprovação (decisão aprovada, alternativas descartadas, tipo de mudança, arquivos-chave, skill expert, flows a revisitar), evitando que o design se perca na compactação de contexto.
- Classificação de mudança (UI-only vs Logic) decidida uma única vez no `brainstorming` e reutilizada pelo `writing-plan`, em vez de reclassificada.
- `writing-plan` grava uma seção **Design de Origem** e cabeçalhos de rastreabilidade (`Design de origem`, `Flows relacionados`) no plano, tornando-o auto-contido.
- `executing-plan` usa o **Design de Origem** como limite ao tratar drift e popula o `related_plans` dos flows atualizados, fechando a rastreabilidade `brainstorm → plan → flow`.

## 1.0.0 — 2026-07-10

- Publicação inicial das cinco skills do Brain Flows.
- Suporte conjunto a Claude Code e Codex.
- Marketplaces e manifestos de plugin para as duas plataformas.
- Instruções internas neutralizadas para seleção de skills e arquivos de projeto.
- Sincronização remota de `plugins/brain-flows/skills/` para `.claude/skills/`, `.agents/skills/` e `.github/skills/`.
