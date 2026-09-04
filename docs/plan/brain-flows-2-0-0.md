# Brain Flows 2.0.0 — dieta de contexto, subagentes com fallback e plano proporcional

> **Objetivo:** Publicar a versão 2.0.0 do plugin com a mesma cadeia de cinco skills carregando ~25% menos instruções por ciclo (~52 KB → ≤ 40 KB no caminho feliz), delegando trabalho verboso a subagentes (sempre com fallback direto) e com um template curto de plano para mudanças de até 2 fases.
> **Design de origem:** brainstorming desta conversa
> **Flows relacionados:** `docs/flow/flow-suggestions.md`, `docs/flow/project-structure.md`, `docs/flow/sync-brain.md`

## Contexto

As versões 1.10–1.13 adicionaram gates de qualidade às quatro skills do ciclo, cada um em uma referência de ~5–7,5 KB (rubrica 0/1/2 + catálogo de 10–14 anti-padrões + falsos positivos) lida a cada invocação. Somadas às skills e aos templates, um ciclo `brainstorming → writing-plan → executing-plan` carrega ~52 KB (~13k tokens) só de instruções, antes de qualquer flow ou código. A regra de context engineering da geração Claude 5 ("julgamento em vez de listas exaustivas", aplicada em 1.7.0 aos `SKILL.md`) nunca chegou às rubricas.

Ao mesmo tempo, as skills fazem na thread principal trabalho cujo output ninguém relê (varredura de código no `flow`, geração de N flows no `flow-init`) e a revisão de conclusão do `executing-plan` é dada pelo mesmo contexto que produziu o código. Subagentes com fallback resolvem os dois pontos sem quebrar a paridade Claude Code ↔ Codex.

## Design de Origem

- **Decisão aprovada:** v2.0.0 = mesma cadeia de cinco skills, com dieta de contexto (rubricas fundidas, bloco multi-parte e ponte `CLAUDE.md` movidos para references, frontmatter alinhado ao spec Agent Skills), delegação neutra a subagentes com fallback (varredura do `flow`, flows paralelos no `flow-init`, revisor independente no `executing-plan`) e template curto de plano para ≤ 2 fases.
- **Alternativas descartadas:** B — camada Claude-only com `context: fork`/hooks nas skills compartilhadas (quebra a paridade com o Codex e o hook de bloqueio colidiria com "rodar o app só se o usuário pedir"); C — molde Superpowers com subagente por tarefa (cada subagente relê plano + instruções + arquivos, multiplicando tokens).
- **Tipo de mudança:** Logic — muda o comportamento das skills. O repositório não tem harness de teste: o contrato é verificado por análise estática (`wc -c`, `grep`, `diff -r` entre espelhos), `claude plugin validate` e os evals de acionamento. Por isso o template B (testes antes) se traduz em: fixar as metas de tamanho e os casos de eval **antes** de reescrever cada arquivo, e verificar contra eles ao final de cada fase.

## Regras de edição válidas para todas as fases

- Editar **somente** em `.claude/skills/<skill>/`; os espelhos (`.agents/`, `.github/`, `plugins/brain-flows/`) são regenerados na Fase 6 por `./package-brain.sh`.
- Nenhuma sintaxe exclusiva de plataforma no corpo das skills. Delegação a subagente é sempre escrita como "se o ambiente oferecer um mecanismo de subagente … senão, execute direto" — o padrão já usado em `executing-plan` 1.9.0.
- Uma regra tem um único lugar canônico: ao mover texto para uma referência, o `SKILL.md` fica só com o ponteiro na tabela "Quando ler".
- Idioma: Português (Brasil).

## Arquitetura / Escopo

| Arquivo | Ação | Responsabilidade |
|---------|------|-----------------|
| `.claude/skills/brainstorming/references/design-review.md` | reescrever | Rubrica de 6 dimensões com anti-padrões B1–B14 fundidos por linha (~2,5 KB) |
| `.claude/skills/writing-plan/references/plan-antipatterns.md` | reescrever | Rubrica de 5 dimensões com P1–P13 fundidos por linha (~2,5 KB) |
| `.claude/skills/executing-plan/references/completion-review.md` | reescrever | Rubrica de 5 dimensões com E1–E10 fundidos por linha (~2,5 KB) |
| `.claude/skills/executing-plan/references/multi-part-execution.md` | criar | Execução parte a parte + delegação de partes (texto hoje no passo 7 do `SKILL.md`) |
| `.claude/skills/executing-plan/SKILL.md` | modificar | Passo 7 enxuto + revisor independente; tabela de referências com a nova entrada |
| `.claude/skills/flow/SKILL.md` | modificar | Passo 2 delega a varredura a subagente somente-leitura, com fallback |
| `.claude/skills/flow-init/SKILL.md` | modificar | Passo 4a paralelo por feature; passo 5c reduzido ao ponteiro para o guia |
| `.claude/skills/flow-init/references/guide-project-instructions.md` | modificar | Seção 2 absorve as regras de ponte do passo 5c que ainda não estão lá |
| `.claude/skills/writing-plan/references/plan-template.md` | modificar | Template curto (≤ 2 fases) e regra de quando cada seção entra |
| `.claude/skills/writing-plan/SKILL.md` | modificar | Passo 2.7 decide entre curto / único / multi-parte |
| `.claude/skills/*/SKILL.md` (5) | modificar | Frontmatter ganha `license: MIT` e `metadata.version: "2.0.0"` |
| `.claude/skills/{writing-plan,executing-plan,flow-init}/evals/evals.json` | modificar | Casos para template curto, revisor independente e flows paralelos |
| `plugins/brain-flows/.claude-plugin/plugin.json`, `plugins/brain-flows/.codex-plugin/plugin.json` | modificar | `version: 2.0.0` |
| `CHANGELOG.md`, `README.md` | modificar | Entrada 2.0.0; README descreve subagentes com fallback e o template curto |
| `docs/flow/flow-suggestions.md`, `docs/flow/project-structure.md` | modificar | Resumos das skills e versão do manifesto atualizados; `related_plans` aponta para este plano |
| `docs/flow/sync-brain.md` | ajustar | Corrigir referências de linha do README deslocadas pela documentação da release e renovar rastreabilidade |

## Fases

### Fase 1 — Rubricas fundidas (contrato: tamanho antes do texto)

> Meta fixada antes de escrever: cada referência ≤ 3.000 bytes (`wc -c`), preservando todos os IDs (B1–B14, P1–P13, E1–E10) e as seis/cinco dimensões nomeadas nos `SKILL.md`.

- [x] Reescrever `.claude/skills/brainstorming/references/design-review.md`: uma tabela `# | Dimensão | 0 → 2 (uma frase) | Anti-padrões (ID + nome, 2–4 palavras cada) | Falso positivo (uma frase)`, com as 6 dimensões atuais (fidelidade à intenção, alternativas honestas, proporcionalidade, densidade, handoff derivável, precisão); manter as linhas de corte (zero bloqueia; 10/12) e a frase "a nota fica na sua análise".
- [x] Reescrever `.claude/skills/writing-plan/references/plan-antipatterns.md` no mesmo formato, 5 dimensões, P1–P13, corte 8/10, mais a linha "se a correção encolher o escopo abaixo do teto de fases, reavalie o formato no passo 2.7".
- [x] Reescrever `.claude/skills/executing-plan/references/completion-review.md` no mesmo formato, 5 dimensões, E1–E10, corte 8/10, mais a linha "julga a execução, não o plano".
- [x] Conferir que os `SKILL.md` de `brainstorming` (Fase 3), `writing-plan` (passo 4.5) e `executing-plan` (passo 7) continuam citando só dimensões que existem nas tabelas novas; ajustar a coluna "Quando ler" das três tabelas de referências para "rubrica de aceite com anti-padrões por dimensão".
- [x] Verificação: `wc -c .claude/skills/*/references/{design-review,plan-antipatterns,completion-review}.md` ≤ 3000 cada; `grep -o 'B1[0-4]\|B[1-9]\b' … | sort -u | wc -l` = 14, idem P = 13 e E = 10; `grep -c 'Falsos positivos' <arquivo>` = 0 (a seção separada deixou de existir).

### Fase 2 — `executing-plan`: multi-parte para referência e revisor independente

- [x] Criar `.claude/skills/executing-plan/references/multi-part-execution.md` com o texto integral dos quatro parágrafos "Em plano multi-parte" do passo 7 atual (delegação de parte com `Delegável`, conferência de evidências, "não pergunte se deve continuar", recorte explícito pelo usuário) e o trecho de leitura seletiva do passo 1 (ler índice + apenas a parte em execução).
- [x] Em `.claude/skills/executing-plan/SKILL.md`, passo 1: substituir o parágrafo multi-parte por uma linha "Plano em pasta (`00-indice.md` + partes): leia `references/multi-part-execution.md` antes de continuar"; passo 7: remover os quatro parágrafos movidos.
- [x] Em `.claude/skills/executing-plan/SKILL.md`, passo 7, adicionar a **revisão independente**: quando a mudança for `Logic` **ou** o plano tiver 3+ fases, e o ambiente oferecer subagente, despachar um revisor em contexto limpo com: caminho do plano (Design de Origem + critérios), `git diff` do escopo e o caminho de `references/completion-review.md`; o revisor devolve nota por dimensão + achados com arquivo/linha; a thread corrige os achados e só então declara conclusão. Fora dessas condições, ou sem subagente, aplicar a rubrica na própria thread como hoje. Regra explícita: achado sem evidência do revisor não vale como reprovação; "concluído" sem evidência do revisor não vale como aprovação.
- [x] Atualizar a tabela de referências do `SKILL.md` com `multi-part-execution.md` ("No passo 1, quando o plano for pasta") e ajustar a linha de `completion-review.md` ("No passo 7 — lida pelo revisor independente ou pela própria thread").
- [x] Verificação: `wc -c .claude/skills/executing-plan/SKILL.md` ≤ 7.500; `grep -c 'Delegável' .claude/skills/executing-plan/SKILL.md` = 0 e `grep -c 'Delegável' .claude/skills/executing-plan/references/multi-part-execution.md` ≥ 2; `grep -c 'revisor' .claude/skills/executing-plan/SKILL.md` ≥ 2.

### Fase 3 — `flow` e `flow-init`: delegação da varredura e flows paralelos

- [x] Em `.claude/skills/flow/SKILL.md`, passo 2 ("Varrer o projeto"): manter o que mapear (camadas, termo de busca, seguir referências) e acrescentar o modo de execução: se o ambiente oferecer subagente somente-leitura, delegar a varredura passando ponto de entrada, resultado esperado e escopo do passo 1, exigindo de volta um mapa estruturado (arquivos por camada com caminho real, ordem de chamada, ramificações existentes, regras de negócio com arquivo, testes existentes); a thread principal escreve o documento a partir do mapa, sem reler os arquivos exceto para confirmar citação em dúvida. Sem subagente, varrer direto como hoje.
- [x] Em `.claude/skills/flow-init/SKILL.md`, passo 4a: se o ambiente oferecer subagentes, despachar um por feature detectada, em paralelo, cada um invocando a skill `flow` para a sua feature e salvando o próprio `docs/flow/<feature>.md` (arquivos disjuntos, sem sobreposição); a thread principal recebe caminho + `status` de cada um e só lista o resultado. Sem subagentes, gerar sequencialmente como hoje. Manter a exigência de que cada flow passe pelas duas checagens da skill `flow`.
- [x] Em `.claude/skills/flow-init/SKILL.md`, passo 5c: reduzir a "Crie ou valide a ponte `CLAUDE.md` conforme a seção 2 do guia"; em `references/guide-project-instructions.md`, seção 2, incorporar os itens do 5c que ainda faltam lá (conteúdo exato `@AGENTS.md` do arquivo novo; preservar instruções exclusivas abaixo do import; não duplicar instruções de `AGENTS.md`).
- [x] Verificação: `wc -c .claude/skills/flow-init/SKILL.md` ≤ 7.000; `grep -c 'subagente' .claude/skills/flow/SKILL.md` ≥ 1 e `.claude/skills/flow-init/SKILL.md` ≥ 1; `grep -c 'symlink' .claude/skills/flow-init/SKILL.md` = 0 e `grep -c 'symlink' .claude/skills/flow-init/references/guide-project-instructions.md` ≥ 1.

### Fase 4 — `writing-plan`: template curto e decisão de formato

- [x] Em `.claude/skills/writing-plan/references/plan-template.md`, adicionar o **Template curto** (para planos de até 2 fases): cabeçalho (`Objetivo`, `Design de origem`, `Flows relacionados`), `Design de Origem` (os três campos), `Fases` (template A ou B) e `Verificação final` (2–3 checkboxes). Declarar explicitamente que Contexto, Arquitetura/Escopo, Riscos e Rollback entram só a partir de 3 fases, e que Critérios de Sucesso passam a existir apenas no formato completo.
- [x] Em `.claude/skills/writing-plan/SKILL.md`, passo 2.7: reescrever como decisão de três saídas pela estimativa de fases — ≤ 2 → template curto; 3–6 → arquivo único completo; > 6 → multi-parte (`references/multi-part-plan.md`). Ajustar a linha da tabela de referências de `plan-template.md` para citar os dois formatos.
- [x] Em `.claude/skills/writing-plan/SKILL.md`, "Regras de Qualidade": remover a regra "Riscos obrigatórios para planos com 3+ fases" (passa a ser consequência do formato completo, definido no template) — lugar canônico único.
- [x] Verificação: `grep -c 'Template curto' .claude/skills/writing-plan/references/plan-template.md` ≥ 1; `grep -c 'Riscos obrigatórios' .claude/skills/writing-plan/SKILL.md` = 0; `grep -c 'template curto' .claude/skills/writing-plan/SKILL.md` ≥ 1.

### Fase 5 — Frontmatter no padrão Agent Skills e evals

- [x] Nos cinco `.claude/skills/*/SKILL.md`, acrescentar ao frontmatter `license: MIT` e `metadata:` com `version: "2.0.0"` (só campos do spec Agent Skills; nada de `context`, `hooks`, `effort`, `paths`).
- [x] Em `.claude/skills/writing-plan/evals/evals.json`, adicionar caso positivo: pedido de mudança pequena (ex.: "crie um plano para trocar o texto do botão e o ícone da tela X") deve gerar plano no template curto, sem Riscos/Rollback.
- [x] Em `.claude/skills/executing-plan/evals/evals.json`, adicionar caso positivo: execução de plano `Logic` deve, ao final, despachar revisor independente quando houver subagente e corrigir os achados antes de declarar conclusão; caso negativo: plano UI-only de 2 fases não despacha revisor.
- [x] Em `.claude/skills/flow-init/evals/evals.json`, adicionar caso positivo: "gere todos os flows" com subagentes disponíveis deve produzir um `docs/flow/<feature>.md` por feature via subagentes paralelos e listar caminho + status.
- [x] Verificação: `for f in .claude/skills/*/SKILL.md; do head -8 "$f" | grep -q 'version: "2.0.0"' || echo "FALTA $f"; done` sem saída; `for f in .claude/skills/*/evals/evals.json; do python3 -m json.tool "$f" >/dev/null || echo "JSON inválido $f"; done` sem saída.

### Fase 6 — Release: espelhos, manifestos, docs e validação

- [x] Rodar `./package-brain.sh` e confirmar com `diff -r .claude/skills plugins/brain-flows/skills && diff -r .claude/skills .agents/skills && diff -r .claude/skills .github/skills` (sem saída).
- [x] Atualizar `version` para `2.0.0` em `plugins/brain-flows/.claude-plugin/plugin.json` e `plugins/brain-flows/.codex-plugin/plugin.json`.
- [x] Adicionar em `CHANGELOG.md` a entrada `## 2.0.0 — <data>` cobrindo: rubricas fundidas (tamanhos antes/depois por `wc -c`), `multi-part-execution.md`, revisor independente, varredura delegada no `flow`, flows paralelos no `flow-init`, ponte `CLAUDE.md` movida ao guia, template curto, frontmatter spec, evals novos. Registrar a carga total do ciclo antes/depois (`wc -c` somado das skills + referências do caminho feliz).
- [x] Atualizar `README.md`: seção 2 (`flow`) e 1 (`flow-init`) mencionam a delegação com fallback; seção 4 menciona o template curto; seção 5 menciona a revisão independente; frase de "Development and packaging" continua válida (sem mudança nos scripts).
- [x] Atualizar `docs/flow/flow-suggestions.md` (resumos das cinco skills refletindo os novos passos) e `docs/flow/project-structure.md` (versão `2.0.0` na tabela de Configuração; linhas de `flow`, `flow-init`, `executing-plan` na tabela de Features), renovando `verified_at`, `source_commit`, `source_state` e adicionando `docs/plan/brain-flows-2-0-0.md` em `related_plans`.
- [x] Verificação: `claude plugin validate .` e `claude plugin validate ./plugins/brain-flows` sem erro; `grep -h '"version"' plugins/brain-flows/.claude-plugin/plugin.json plugins/brain-flows/.codex-plugin/plugin.json` mostra `2.0.0` duas vezes; `codex plugin marketplace add "$PWD"` sem erro; soma de `wc -c` de `brainstorming/SKILL.md + design-review.md + writing-plan/SKILL.md + plan-template.md + plan-antipatterns.md + executing-plan/SKILL.md + completion-review.md` ≤ 40.000 bytes (era ~52.000).

> Evidência: `claude plugin validate .` e `claude plugin validate ./plugins/brain-flows` retornaram `Validation passed` (exit 0); `codex plugin marketplace add "$PWD"` retornou `already added` (exit 0); os dois manifestos mostram `2.0.0`, o `diff -r` dos quatro diretórios não produziu saída (exit 0) e a soma medida foi 34.015 bytes.

> Desvio registrado: `docs/flow/sync-brain.md` foi incluído na Fase 6 para corrigir citações de linhas do `README.md` deslocadas pelas alterações desta release e referências de linhas do próprio script; a estrutura e o comportamento documentados do script não mudaram.

## Critérios de Sucesso

- [x] As três rubricas têm ≤ 3.000 bytes cada e preservam todos os IDs de anti-padrão.
- [x] `executing-plan/SKILL.md` ≤ 7.500 bytes e o texto multi-parte vive só em `references/multi-part-execution.md`.
- [x] Carga do caminho feliz do ciclo ≤ 40 KB (medida na Fase 6).
- [x] `flow`, `flow-init` e `executing-plan` descrevem delegação a subagente sempre acompanhada do fallback direto, sem citar ferramenta ou plataforma.
- [x] `plan-template.md` contém o Template curto e o passo 2.7 decide entre três formatos.
- [x] Os quatro diretórios de skills são idênticos (`diff -r` vazio) e os dois `plugin.json` estão em `2.0.0`.
- [x] `claude plugin validate` passa nos dois alvos.
- [ ] _(manual — feito pelo usuário)_ Benchmark A/B com `skill-creator` (1.13.0 vs 2.0.0): tokens por invocação menores e taxa de acionamento igual ou maior; um ciclo real `brainstorming → writing-plan → executing-plan` em projeto de destino com subagentes disponíveis, conferindo que a delegação dispara e o fallback funciona no Codex.

## Riscos e Mitigações

| Risco | Probabilidade | Mitigação |
|-------|--------------|-----------|
| Rubrica fundida perde poder corretivo (o catálogo detalhado primava o julgamento) | Média | Cada linha mantém ID + nome do anti-padrão; o benchmark A/B manual é o critério de reverter para o formato longo em uma dimensão específica |
| Revisor independente encarece plano pequeno | Baixa | Gate por `Logic` ou 3+ fases; fora disso, autoavaliação como em 1.13.0 |
| Subagente de varredura devolve mapa incompleto e o flow cita arquivo inexistente | Média | A checklist de autorrevisão do `flow` (todos os arquivos citados existem?) continua obrigatória na thread principal; citação em dúvida é confirmada com leitura direta |
| Flows paralelos no `flow-init` excedem o orçamento de tokens do usuário | Baixa | A delegação é opcional; o passo 3 já exige confirmação antes de gerar todos os flows |
| Texto Claude-only entra por descuido nas skills compartilhadas | Baixa | Verificação da Fase 5 restringe o frontmatter; regra de edição no topo deste plano cobre o corpo |

## Rollback

`git revert` do(s) commit(s) desta versão e `./package-brain.sh` para realinhar os quatro diretórios; voltar `version` para `1.13.0` nos dois `plugin.json`. Nenhum consumidor é afetado até rodar `./sync-brain.sh`, que sempre baixa a `main` atual.
