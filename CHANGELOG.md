# Changelog

Todas as mudanças relevantes deste projeto serão registradas aqui.

## 1.6.0 — 2026-07-24

- `brain-agent-loop` é dividido em dois agentes locais para permitir modelos diferentes por metade do ciclo: `brain-agent-loop` (`model: opus`) passa a cobrir só `brainstorming` + `writing-plan`, e um novo `brain-agent-loop-exec` (`model: sonnet`) cobre `executing-plan` + commit/push/PR. Um único agente não pode trocar de modelo no meio da própria execução — a troca só é possível delegando a um segundo agente via ferramenta Agent.
- `brain-agent-loop` cria o worktree isolado (`EnterWorktree`) antes do brainstorming — para que o plano já nasça isolado — e, ao salvar o plano, delega a `brain-agent-loop-exec` em foreground, sem `isolation` na chamada, para que o segundo agente herde o mesmo worktree/branch em vez de criar outro.
- `brain-agent-loop-exec` fica responsável pelo commit, `git push`, `gh pr create` e pelo `ExitWorktree` (remove com PR aberta, keep sem PR) — responsabilidade que antes estava toda em `brain-agent-loop`.
- `sync-brain.sh` ganha `brain-agent-loop-exec` em `BRAIN_AGENTS`. Ambos os agentes continuam fora do plugin e só sincronizados para `.claude/agents/`, pelos mesmos motivos de sempre: subagents de plugin ignoram `permissionMode` e `model`, e o Codex não tem equivalente com modo de permissão ou modelo por subagent.

## 1.5.0 — 2026-07-24

- `writing-plan` deixa de tratar mudança **UI-only** como sempre "sem testes". Quando a stack tem framework de **teste de componente headless** (widget/component test que roda no test harness, sem device), o plano passa a incluir uma fase de teste de componente **depois** de a UI existir — validando render e interação sem executar o app.
- Nova subseção em `1.5. Classificar o tipo de mudança` distingue explicitamente "rodar o app" (emulador/simulador/device/browser/E2E/instrumentado — proibido) de "teste de componente headless" (permitido e preferido), com tabela por stack (Flutter `flutter test`, React/RN Testing Library, Vue Test Utils, Angular TestBed, Compose+Robolectric, SwiftUI ViewInspector) e o par instrumentado equivalente que NÃO deve ser usado.
- Detecção da capacidade é por **inspeção das dependências do projeto** (`pubspec.yaml`, `package.json`, `build.gradle`, `Package.swift`). Sem framework headless confirmado, mantém o comportamento antigo (UI-only sem testes) — nunca rodar o app para compensar.
- Template A ganha uma fase opcional de teste de componente; a regra de qualidade "Verificação nunca executa o app" foi reescrita para deixar claro que testar componente no harness não é rodar o app; Critérios de Sucesso ganham a linha condicional de testes de componente/widget.
- Apenas a skill `writing-plan` mudou; `executing-plan` já permitia rodar testes no harness. Espelhada nos quatro diretórios (`.claude/`, `.agents/`, `.github/`, `plugins/brain-flows/`).

## 1.4.0 — 2026-07-24

- `agent-loop` deixa de ser skill distribuída pelo plugin e passa a ser um agente local em `.claude/agents/agent-loop.md`, com `permissionMode: bypassPermissions` — pula os prompts de confirmação de ferramentas (Bash, Edit, Write etc.) para quem invocá-lo, sem depender de configuração externa de sessão.
- Motivo da mudança de local: subagents dentro de um plugin ignoram o campo `permissionMode` (a permissão pedida nunca teria efeito real se `agent-loop` continuasse empacotado), e o Codex não tem equivalente a subagent com modo de permissão próprio — mantê-lo como skill quebraria a paridade entre plataformas.
- Removido de `BRAIN_SKILLS` em `sync-brain.sh` e `package-brain.sh`, dos quatro espelhos de skills (`.claude/`, `.agents/`, `.github/`, `plugins/brain-flows/`) e dos testes de acionamento em `submission/evals.json`. O pacote do plugin volta a ter cinco skills.
- `sync-brain.sh` ganha uma segunda lista, `BRAIN_AGENTS`, para sincronizar agentes locais: busca `.claude/agents/<agente>.md` direto do repositório-fonte (fora do plugin) e copia para `.claude/agents/` local, sem `package-brain.sh` equivalente — `.claude/agents/` é a própria fonte de verdade.
- `agent-loop` passa a isolar todo o ciclo num worktree (`EnterWorktree`) antes de começar e a fechar com commit + `git push` + `gh pr create` em vez de deixar as mudanças soltas na branch atual — o contrapeso necessário para rodar com `bypassPermissions` sem tocar no trabalho que o usuário já tinha em andamento. Sem remoto configurado ou `gh` autenticado, trata a ausência de PR como limite real de capacidade e mantém o worktree com as mudanças commitadas.

## 1.3.1 — 2026-07-24

- `agent-loop` deixa de exigir aprovação humana em qualquer ponto do ciclo: a própria skill escolhe a alternativa de design recomendada na Fase 5 do `brainstorming` (registrando o motivo da escolha) e segue direto por `writing-plan` e `executing-plan` sem nenhuma pausa de confirmação. Continua sendo acionada somente por pedido explícito de autonomia total; pedidos que só querem pular a pausa entre plano e execução, mantendo a aprovação do design, não acionam mais este modo.
- Limites reais de capacidade (credencial ausente, dependência externa impossível) deixam de interromper o fluxo pedindo permissão — a skill escolhe o caminho mais razoável e relata a limitação no resumo final.

## 1.3.0 — 2026-07-23

- `brainstorming` Fase 1: a seleção de flows deixa de partir do nome do arquivo e passa a ler o resumo de **todos** os flows de uma vez (`grep '**Resumo:**' docs/flow/*.md`), escolhendo por relevância semântica quais abrir por completo. Corrige o falso negativo silencioso em que um flow relevante nunca era aberto porque o nome do arquivo não batia com as palavras-chave do pedido — problema que se agrava em projetos com muitos flows (15+).
- Mantido o fallback para `ls ./docs/flow/` quando não há linha de resumo, e a postura de não bloquear na ausência de flows.
- Sem novos artefatos, scripts ou índices: a fonte de verdade continua sendo apenas os arquivos de flow, sem duplicação a manter sincronizada.

## 1.2.0 — 2026-07-22

- Simplificação da skill `brainstorming`: reescrita de 223 para 120 linhas, mantendo comportamento e contrato de handoff.
- Redução de 7 para 5 fases: as antigas Fases 1, 2 e 2.5 (intenção, flows e detecção de `*-expert`) fundem-se em **Fase 1 — Intenção e contexto**; o plumbing de detecção de expert por plataforma foi condensado.
- Eliminação de redundância entre briefing, design e handoff: `Arquivos-chave`, `Skill expert` e `Flows a revisitar` passam a viver apenas no bloco **Handoff**; as seções "Contexto Carregado" e "Responsabilidade após a implementação" saíram do briefing.
- Preservados intactos: o gate da Fase 0 (dispensar mudança mecânica), a comparação de alternativas com recomendação, o bloco **Handoff para o Plano** e o campo **Tipo de mudança**.

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
