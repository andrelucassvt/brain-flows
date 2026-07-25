# Changelog

Todas as mudanças relevantes deste projeto serão registradas aqui.

## 1.7.0 — 2026-07-25

Aplicação das recomendações de context engineering para modelos da geração Claude 5 ([artigo](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models)): disclosure progressivo, uma regra num único lugar canônico e julgamento em vez de listas exaustivas.

- **Templates movidos para `references/`.** `writing-plan` ganha `references/plan-template.md` (estrutura obrigatória + templates A/B de fases) e `references/headless-testing.md`; `flow` ganha `references/flow-template.md` (template + checklist de autorrevisão); `flow-init` ganha `references/document-templates.md` (`project-structure.md` e `flow-suggestions.md`). Os `SKILL.md` mantêm o fluxo de decisão e uma tabela de "quando ler cada referência", carregada sob demanda em vez de sempre.
- **Redução de contexto por invocação:** `writing-plan` 232 → 115 linhas, `flow` 162 → 83, `flow-init` 257 → 150. O conteúdo não foi perdido, apenas deixou de entrar no contexto antes do passo que o usa.
- **A regra de "não rodar o app" passa a ter um lugar canônico.** Estava repetida em cinco pontos com formulações divergentes — inclusive uma, em `executing-plan`, que a condicionava a "quando o plano reserva a validação ao usuário", abrindo brecha que as outras fechavam. Agora a definição completa vive em `writing-plan/references/headless-testing.md`, `executing-plan` traz uma única linha sem condicional, e o bloco destinado ao `AGENTS.md` do projeto de destino saiu do `SKILL.md` de `flow-init` para a seção 4.1 do guia.
- **Tabela de stacks deixa de ser regra e passa a ser apoio.** A detecção de teste de componente headless continua sendo por inspeção das dependências do projeto; a tabela por stack virou referência explicitamente não exaustiva, para não travar o julgamento em seis stacks conhecidas.
- **Fase 0 do `brainstorming` troca a lista de casos** (typo, rename, formatação, constante…) pelo critério que a origina: mudança puramente mecânica, sem decisão a tomar.
- **`description` das skills padronizada em português** e sem `MUST` coercitivo — `brainstorming` e `flow` estavam em inglês, com o resto em português, o que piorava o matching de acionamento.
- **Regra "Idioma" removida das cinco skills** (comportamento padrão do modelo), preservando só o que não é óbvio: `executing-plan` mantém "preserve o idioma do plano" e `flow`/`flow-init` registram que o documento herda o idioma da conversa.
- **Agentes locais enxugados.** `brain-agent-loop` (45 → 38 linhas) e `brain-agent-loop-exec` (39 → 34) perdem a duplicação quase literal das seções de autonomia/isolamento; o passo 0 "verificar o isolamento" saiu, porque `isolation: worktree` já é garantia do harness — a orientação de não chamar `EnterWorktree`/`ExitWorktree` permanece como uma linha.
- `AGENTS.md` ganha a convenção de `SKILL.md` + `references/` e delimita `docs/flow/` (conhecimento estrutural do repositório) frente à memória automática do agente (contexto de sessão), para os dois não competirem.
- Sem mudança de comportamento nas skills: mesma cadeia, mesmos artefatos, mesmos templates. Espelhado nos quatro diretórios (`.claude/`, `.agents/`, `.github/`, `plugins/brain-flows/`).

## 1.6.0 — 2026-07-24

- `brain-agent-loop` é dividido em dois agentes locais para permitir modelos diferentes por metade do ciclo: `brain-agent-loop` (`model: opus`) passa a cobrir só `brainstorming` + `writing-plan`, e um novo `brain-agent-loop-exec` (`model: sonnet`) cobre `executing-plan` + commit/push/PR. Um único agente não pode trocar de modelo no meio da própria execução — a troca só é possível delegando a um segundo agente via ferramenta Agent.
- `brain-agent-loop` passa a declarar `isolation: worktree` no frontmatter, deixando o Claude Code criar o worktree antes do agente iniciar; o agente apenas verifica o isolamento e interrompe diante de erro de configuração, sem recorrer a `EnterWorktree` nem à criação manual. Ao salvar o plano, delega a `brain-agent-loop-exec` em foreground, sem novo `isolation`, para que o segundo agente herde o mesmo worktree/branch.
- `brain-agent-loop-exec` fica responsável pelo commit, `git push` e `gh pr create`, mas nenhum dos dois agentes chama `ExitWorktree`: a limpeza fica sob responsabilidade do ciclo de vida do Claude Code, enquanto falhas e interrupções preservam e reportam o caminho e a branch do worktree.
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
