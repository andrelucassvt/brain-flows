# Changelog

Todas as mudanças relevantes deste projeto serão registradas aqui.

## 1.13.0 — 2026-08-25

Saída do `brainstorming` reformatada para densidade. O conteúdo auditado em 1.12.0 estava correto, mas chegava ao usuário em duas entregas longas — briefing e design — com seções previsíveis que ninguém lia. Mesma informação, uma resposta, com orçamento de linhas.

- **Fases 2 e 3 fundidas em "Fase 2 — Entrega única"**: contexto, alternativas e design saem juntos. O template de briefing com cinco seções fixas (`Entendimento do Pedido`, `O que já existe`, `Pontos de Atenção`, `Boas Práticas Disponíveis`, `Próximos Passos Sugeridos`) deu lugar a uma linha de decisão (`decisão · tipo · N arquivos`), uma linha `⚠️` opcional, uma tabela de opções e quatro bullets de design. `Entendimento do Pedido` e `Próximos Passos Sugeridos` foram cortados por serem previsíveis; a skill expert vive só no Handoff, onde já era campo.
- **Orçamento explícito**: ≤ 15 linhas em mudança pequena, ≤ 40 em mudança ampla, sem contar o Handoff. Estourar se corrige cortando seção, não comprimindo prosa.
- **Alternativas viraram tabela** (`Opção | O que muda | Trade-off`) em vez de listas aninhadas de vantagens/desvantagens — o mesmo trade-off em uma linha por opção, com o ✅ carregando a recomendação.
- **Handoff marcado como interface de máquina**, sob `<!-- para o writing-plan -->`, entregue depois da aprovação. Os seis campos e o contrato com o `writing-plan` seguem inalterados.
- **Rubrica ganha a dimensão 4, "Densidade"** (corte agora em 10/12), com os anti-padrões novos **B12** (pedido devolvido), **B13** (processo narrado) e **B14** (redundância entre seções); B7 foi realocado para ela. Novo falso positivo: nenhuma linha de contexto quando o pedido é claro. Fase 3.5 renumerada para Fase 3.
- **Nova regra geral "Não narre o processo"** — o usuário recebe o resultado, não o percurso.

## 1.12.0 — 2026-08-04

Gate de qualidade chega ao `brainstorming`, o primeiro elo da cadeia e o último sem auditoria. As quatro skills do ciclo passam a auditar a própria saída antes de entregá-la à seguinte.

- **Nova referência `brainstorming/references/design-review.md`** — primeira `references/` desta skill. Rubrica de aceite com 5 dimensões (fidelidade à intenção, alternativas honestas, proporcionalidade, handoff derivável, precisão) pontuadas 0/1/2, catálogo B1–B11 (pedido reinterpretado, suposição silenciosa, alternativa de palha, alternativa clonada, recomendação sem critério, design especulativo, briefing enciclopédico, handoff genérico, classificação por aparência, caminho inventado, deprecated silencioso) e 8 falsos positivos.
- **Nova Fase 3.5 no `brainstorming/SKILL.md`** ("Auditar antes de apresentar"): a rubrica roda com o design escrito e ainda não apresentado, antes de gastar a aprovação do usuário. A dimensão **handoff derivável** é o elo com o `writing-plan` — ela reprova o design que não permite preencher **Decisão aprovada**, **Tipo de mudança** e **Arquivos-chave**, campos que a rubrica do `writing-plan` (dimensão 3, anti-padrões P8/P9) já pressupunha bem formados sem ninguém auditar sua origem. Em design apresentado em partes, cada parte é auditada antes de ir ao usuário.
- **Regras Gerais do `brainstorming` enxugadas**: "Seja preciso" e "Nada deprecated" viraram B10 e B11 no catálogo, mantendo o lugar canônico único — mesmo movimento feito no `writing-plan` em 1.10.0. "Não bloqueie" permanece no `SKILL.md` por ser regra de geração, não critério de auditoria.
- **`flow-init` alinhado ao `flow` 1.11.0**: o Passo de verificação exigia apenas "a autorrevisão definida na skill `flow`", mas o passo 5 do `flow` passou a exigir duas checagens. Agora nomeia as duas (checklist de autorrevisão + critérios de utilidade) como condição para `status: current`.

## 1.11.0 — 2026-08-04

Gate de qualidade propagado para `executing-plan` e `flow`, fechando as três pontas da cadeia. `package-brain.sh` passa a distribuir para os quatro diretórios.

- **Nova referência `executing-plan/references/completion-review.md`** — primeira `references/` desta skill. Rubrica de conclusão com 5 dimensões (cobertura, evidência, fidelidade, integridade, rastreabilidade) pontuadas 0/1/2, catálogo E1–E10 (checkbox otimista, afirmação no lugar da verificação, evidência obsoleta, verificação afrouxada, drift silencioso, escopo infiltrado, ampliação por conveniência, flow órfão, plano reescrito, conclusão com ressalva) e 7 falsos positivos. Julga a execução, não o plano.
- **Passo 7 do `executing-plan` reescrito.** A lista de cinco conferências manuais virou: rodar as verificações finais e aplicar a rubrica. Um zero em qualquer dimensão impede declarar o plano concluído; sem resolução dentro do escopo, o resultado é relato de bloqueio, não fechamento.
- **`flow/references/flow-template.md` ganha "Critérios de utilidade"**, complementando a checklist de autorrevisão existente: ela garante que o documento está certo, os critérios garantem que ele serve. Quatro perguntas (Resumo discrimina no `grep` do `brainstorming`? dá para depurar sem abrir o código? as regras são de negócio ou controle de fluxo? as Observações dizem algo que o código não diz?), catálogo F1–F5 e falsos positivos. Passo 5 do `flow/SKILL.md` passa a exigir as duas checagens para marcar `status: current`.
- **`package-brain.sh` distribui para os quatro diretórios** (`.agents/`, `.github/`, `plugins/brain-flows/`) a partir de `.claude/skills/`, em vez de só o plugin. `.github/skills/` saiu do `sync-brain.sh` no commit `cbe6fc7` e desde então nenhum script o atualizava — este passa a ser o único caminho que o mantém em dia. `AGENTS.md` atualizado com o papel real de cada script.

## 1.10.0 — 2026-08-04

Gate de qualidade no `writing-plan`: o plano passa a ser auditado contra uma rubrica antes de ser salvo, em vez de sair direto da geração.

- **Nova referência `writing-plan/references/plan-antipatterns.md`**, com três partes: rubrica de aceite (5 dimensões — acionabilidade, verificabilidade, fidelidade ao design, proporcionalidade, retomabilidade — pontuadas 0/1/2, corte em 8/10 e zero em qualquer dimensão bloqueando), catálogo de 13 anti-padrões nomeados (P1–P13, cada um com sintoma e correção) e uma lista de falsos positivos que impede a auditoria de podar complexidade legítima.
- **Novo passo 4.5 no `writing-plan/SKILL.md`** ("Auditar antes de salvar"): com o plano escrito e ainda não salvo, aplica a rubrica, corrige o que ela reprovar e só então grava o arquivo. No modo multi-parte, audita cada parte e o índice; se a correção encolher o escopo abaixo do teto de fases, o formato é reavaliado no passo 2.7.
- **Passo 2.5 ("Revisão de simplicidade") removido.** A checagem de over-engineering acontecia antes de as fases existirem e passava a duplicar o catálogo; virou a dimensão de proporcionalidade da rubrica (anti-padrões P10–P12), num único ponto de auditoria.
- **Regras de Qualidade enxugadas**: "Passos acionáveis" e "Sem placeholders vagos" saíram do `SKILL.md` e viraram P1–P3 no catálogo, mantendo o lugar canônico único. As demais regras (fases sequenciais, tamanho de fase, teto de fases, riscos obrigatórios, verificação não executa o app) continuam no `SKILL.md` por serem regras de geração, não critérios de auditoria.
- Espelhado nos quatro diretórios (`.claude/`, `.agents/`, `.github/`, `plugins/brain-flows/`).

## 1.9.1 — 2026-08-02

Plano multi-parte passa a ser executado até o fim: o checkpoint entre partes deixa de ser pausa para aprovação.

- **`executing-plan` não pergunta mais se deve continuar.** Após concluir uma parte (status marcado no índice + commit + resumo curto), segue direto para a próxima parte pendente com dependências satisfeitas, repetindo os passos 1–5 até a última. A pausa passa a existir só por bloqueio real (verificação que falha fora do escopo do passo, dependência externa ausente, correção que mudaria o design aprovado) ou quando o usuário recorta explicitamente o pedido ("execute só a parte 2").
- **Checkpoint redefinido em `writing-plan/references/multi-part-plan.md`**: continua sendo commit por entrega fechada e ponto de retomada caso a sessão caia, mas não é ponto de aprovação. O checkbox de encerramento das partes agora diz "commit + resumo curto do que ficou pronto, seguindo direto para a parte N+1".
- Redação do passo 2.7 do `writing-plan/SKILL.md` alinhada: a divisão em partes existe para o contexto, não para pausar a execução.
- Espelhado nos quatro diretórios (`.claude/`, `.agents/`, `.github/`, `plugins/brain-flows/`).

## 1.9.0 — 2026-07-29

Delegação de partes de plano multi-parte para subagentes: partes mecânicas e verificáveis param de consumir o contexto da thread principal.

- **`writing-plan/references/multi-part-plan.md` ganha critérios de delegabilidade.** Nova subseção "Avaliar delegação para subagentes" na seção "Como fatiar", com 5 critérios (todos verdadeiros para `sim`): contexto auto-contido, arquivos disjuntos das demais partes pendentes, verificação 100% automatizada com critério binário, sem decisão de design em aberto, e blast radius contido. Duas regras derivadas: parte UI-only sem teste headless é sempre `não`; a delegação é sempre por parte inteira.
- **Nova coluna `Delegável` no template do `00-indice.md`**, entre "Entrega" e "Depende de", no formato `sim/não — motivo curto` — o motivo curto força a avaliação explícita em vez de um `sim`/`não` mecânico.
- **`executing-plan` despacha partes delegáveis a subagentes, com fallback.** No passo 1, o índice passa a informar também a coluna `Delegável` da parte selecionada. No passo 7, se a parte estiver marcada `sim` e o ambiente oferecer um mecanismo de subagente, a parte inteira é delegada — o subagente recebe o arquivo da parte e do índice, executa todos os passos, marca os checkboxes e roda as verificações; o retorno exigido são as evidências das verificações, e o orquestrador confere essas evidências antes de marcar o status da parte no índice. Sem suporte a subagentes no ambiente, ou parte marcada `não`, a execução segue normal, passo a passo — a delegação é sempre otimização, nunca requisito. Redação neutra entre plataformas, sem citar ferramenta, modelo ou modo de permissão específico.
- Critérios de delegação vivem só no reference; os dois `SKILL.md` apenas apontam para eles, sem repetir.
- Espelhado nos quatro diretórios (`.claude/`, `.agents/`, `.github/`, `plugins/brain-flows/`).

## 1.8.0 — 2026-07-27

Plano multi-parte: escopo grande deixa de virar um monólito de 10+ fases executado numa maratona única.

- **`writing-plan` ganha teto de fases e modo multi-parte.** Novo passo 2.7 ("Estimar o tamanho e decidir o formato"): estimativa acima de ~6 fases gera uma pasta `docs/plan/<nome>/` com `00-indice.md` (objetivo, Design de Origem, tabela de partes com ordem/dependências/status e riscos globais) + partes numeradas (`01-...md`, `02-...md`), cada uma um plano completo de até ~6 fases no formato atual (templates A/B). O plano completo continua pronto de uma vez — a divisão existe para a execução acontecer em sessões curtas com checkpoint natural (commit + validação) entre partes. Planos de até 6 fases seguem arquivo único, sem mudança.
- **Nova referência `writing-plan/references/multi-part-plan.md`** com o layout da pasta, a regra de fatiamento (cada parte é uma entrega fechada, fatiada por valor e não por camada), o template do índice e os dois ajustes das partes (cabeçalho enxuto apontando para o índice — o Design de Origem vive só lá — e checkbox de checkpoint no encerramento).
- **`executing-plan` executa parte a parte.** No plano multi-parte, lê o índice + apenas a parte em execução (a primeira pendente com dependências satisfeitas), sem carregar partes futuras no contexto; ao concluir uma parte, marca o status no índice, executa o checkpoint e **para**, deixando a decisão de continuar com o usuário. Atualização de flows e declaração de conclusão só na última parte.
- **Novo eval em `writing-plan/evals/evals.json`** cobrindo o acionamento do modo multi-parte: escopo grande (módulo de assinaturas completo) deve gerar pasta com índice + partes completas, teto de fases por parte, checkpoints e cobertura integral do escopo.
- Espelhado nos quatro diretórios (`.claude/`, `.agents/`, `.github/`, `plugins/brain-flows/`).

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
