# Delegação de Partes do Plano Multi-parte para Subagentes

> **Objetivo:** Permitir que o `writing-plan` avalie, ao fatiar um plano multi-parte, quais partes podem ser executadas por subagentes, marque isso no índice, e o `executing-plan` despache essas partes — com fallback para execução normal quando a plataforma não suportar subagentes.
> **Design de origem:** brainstorming desta conversa
> **Flows relacionados:** `docs/flow/project-structure.md`

## Contexto

O modo multi-parte (v1.8.0) já fatia planos grandes em partes auto-contidas com checkpoint entre elas, mas toda a execução acontece na thread principal — cada parte mecânica consome o contexto da sessão. Partes com verificação objetiva e arquivos disjuntos podem ser delegadas a subagentes, isolando contexto, desde que a avaliação aconteça no momento do fatiamento (quem desenha as dependências é quem sabe o que é independente) e fique registrada no plano.

## Design de Origem

- **Decisão aprovada:** Critérios de delegabilidade inline na seção "Como fatiar" de `references/multi-part-plan.md`, coluna `Delegável` (sim/não + motivo curto) na tabela do `00-indice.md`, e despacho genérico com fallback no `executing-plan` — granularidade de parte inteira.
- **Alternativas descartadas:** Reference novo `delegation.md` (leitura extra, separa a avaliação do momento do fatiamento); avaliação na execução (perde o momento do fatiamento e o registro); delegação por fase (fragmenta o checkpoint); paralelismo entre partes e seleção de modelo por parte (fora de escopo).
- **Tipo de mudança:** Logic — com ressalva registrada no brainstorming: não é código de app, é Markdown de skills; não há TDD clássico. As fases seguem ordem segura (reference → skills → empacotamento → flow) com verificação estática (validadores de plataforma, diff entre espelhos), sem fase de testes.

## Arquitetura / Escopo

| Arquivo | Ação | Responsabilidade |
|---------|------|-----------------|
| `.claude/skills/writing-plan/references/multi-part-plan.md` | editar | Recebe os critérios de delegabilidade na seção "Como fatiar" e a coluna `Delegável` no template do `00-indice.md` |
| `.claude/skills/writing-plan/SKILL.md` | editar | Passo 2.7 menciona a avaliação de delegabilidade (sem repetir os critérios); descrição da linha do `multi-part-plan.md` na tabela de referências |
| `.claude/skills/executing-plan/SKILL.md` | editar | Passo 1 absorve a coluna `Delegável` do índice; passo 7 (multi-parte) ganha o despacho a subagente com fallback |
| `plugins/brain-flows/skills/` | regenerar | `package-brain.sh` propaga as três edições à fonte canônica do plugin |
| `.agents/skills/`, `.github/skills/` | regenerar | Espelhamento via `rsync` a partir de `.claude/skills/` (o `sync-brain.sh` só atualiza após push) |
| `plugins/brain-flows/.claude-plugin/plugin.json` + `.codex-plugin/plugin.json` | editar | Bump de versão 1.8.0 → 1.9.0 (mesma versão nos dois) |
| `CHANGELOG.md` | editar | Entrada 1.9.0 descrevendo a feature |
| `docs/flow/project-structure.md` | editar | Descrições de `writing-plan`/`executing-plan` refletindo a delegação; metadados de verificação |

## Fases

### Fase 1 — Critérios de delegabilidade no `multi-part-plan.md`

- [x] Em `.claude/skills/writing-plan/references/multi-part-plan.md`, adicionar na seção "Como fatiar" uma subseção "Avaliar delegação para subagentes" com os 5 critérios (todos verdadeiros para `sim`): contexto auto-contido (a parte se executa lendo só o próprio arquivo + código referenciado); arquivos disjuntos das demais partes pendentes; verificação 100% automatizada com critério binário; sem decisão de design em aberto (a Decisão aprovada cobre a parte inteira); blast radius contido (não abre contrato que outra parte consome)
- [x] Registrar na subseção as duas regras derivadas: parte UI-only sem teste headless é sempre `não` (a evidência é a validação funcional do usuário); a delegação é por parte inteira — o subagente executa do primeiro ao último checkbox, marca os checkboxes no arquivo da parte e roda as verificações
- [x] No template do `00-indice.md`, adicionar a coluna `Delegável` na tabela de partes, entre "Entrega" e "Depende de", com formato `sim — <motivo curto>` / `não — <motivo curto>`, e uma linha explicando que o motivo curto força a avaliação explícita
- [x] Verificação: `grep -n 'Delegável' .claude/skills/writing-plan/references/multi-part-plan.md` mostra a coluna no template e os critérios presentes; critérios não repetidos em nenhum outro arquivo da skill (`grep -rn 'deleg' .claude/skills/writing-plan/` — ocorrências apenas no reference e em menções de apontamento)

### Fase 2 — Ajustes no `writing-plan/SKILL.md`

- [x] No passo 2.7 de `.claude/skills/writing-plan/SKILL.md`, adicionar uma frase apontando que o fatiamento inclui avaliar a delegabilidade de cada parte conforme o reference — sem repetir os critérios (lugar canônico único)
- [x] Atualizar a descrição da linha `references/multi-part-plan.md` na tabela "Referências" para incluir a avaliação de delegação (ex.: "…estrutura da pasta, do índice, das partes e a avaliação de delegação para subagentes")
- [x] Verificação: o passo 2.7 menciona delegação apenas como apontamento; `grep -c 'Delegável' .claude/skills/writing-plan/SKILL.md` não introduz os critérios duplicados (no máximo menção à coluna)

### Fase 3 — Despacho no `executing-plan/SKILL.md`

- [x] No passo 1 (parágrafo "Plano multi-parte") de `.claude/skills/executing-plan/SKILL.md`, incluir a coluna `Delegável` entre os dados absorvidos do índice ao selecionar a parte em execução
- [x] No passo 7 (bloco "Em plano multi-parte"), adicionar o comportamento de despacho: se a parte estiver marcada `sim` **e** a plataforma suportar subagentes, delegar a parte inteira — o subagente recebe o caminho do arquivo da parte (e do índice), executa todos os passos, marca os checkboxes no arquivo e roda as verificações definidas; o retorno exigido são as evidências das verificações
- [x] Registrar que o orquestrador confere as evidências retornadas antes de marcar o status da parte no índice e executar o checkpoint — checkbox marcado pelo subagente sem evidência confirmada não vale
- [x] Registrar o fallback: plataforma sem suporte a subagentes executa a parte normalmente (passo a passo, como hoje) — a delegação é otimização, nunca requisito; a redação deve ser neutra, sem nomear ferramenta, modelo ou modo de permissão de plataforma específica
- [x] Verificação: `grep -n -i 'subagente' .claude/skills/executing-plan/SKILL.md` mostra o despacho e o fallback; nenhuma menção a `permissionMode`, `model` ou nomes de ferramentas exclusivos do Claude Code/Codex

### Fase 4 — Empacotamento, espelhamento e release

- [x] Rodar `./package-brain.sh` para regenerar `plugins/brain-flows/skills/` a partir de `.claude/skills/`
- [x] Espelhar os dois diretórios restantes: `rsync -a --delete .claude/skills/writing-plan/ .agents/skills/writing-plan/ && rsync -a --delete .claude/skills/executing-plan/ .agents/skills/executing-plan/` e o mesmo par para `.github/skills/`
- [x] Verificação: `diff -r .claude/skills/writing-plan plugins/brain-flows/skills/writing-plan` e os diffs equivalentes para `executing-plan`, `.agents/` e `.github/` retornam vazio
- [x] Bump de versão para `1.9.0` em `plugins/brain-flows/.claude-plugin/plugin.json` e `plugins/brain-flows/.codex-plugin/plugin.json` (mesma versão nos dois)
- [x] Adicionar entrada `## 1.9.0 — <data>` no `CHANGELOG.md`, no estilo das entradas existentes: delegação de partes para subagentes, critérios no `multi-part-plan.md`, coluna no índice, despacho com fallback no `executing-plan`, espelhamento nos quatro diretórios
- [x] Verificação: `claude plugin validate .` e `claude plugin validate ./plugins/brain-flows` passam (se o CLI não estiver disponível, registrar que ficou para o usuário)

### Fase 5 — Atualizar Flow

- [x] Em `docs/flow/project-structure.md`, atualizar a descrição da skill `writing-plan` na tabela Features (avalia delegabilidade das partes no modo multi-parte) e a de `executing-plan` (despacha partes delegáveis a subagentes, com fallback)
- [x] Atualizar o resumo do modo multi-parte no texto de Arquitetura se necessário para mencionar a delegação opcional — não aplicável: o texto de Arquitetura nunca descreveu o modo multi-parte (só a cadeia de skills e os agentes locais), não havia resumo a atualizar
- [x] Renovar metadados: `verified_at` com a data da execução e `related_plans` incluindo `docs/plan/subagent-delegation.md`
- [x] Verificação: `grep -n 'deleg' docs/flow/project-structure.md` mostra as descrições atualizadas

## Critérios de Sucesso

- [x] `multi-part-plan.md` contém os 5 critérios de delegabilidade e a coluna `Delegável` no template do índice, idêntico nos quatro diretórios (`.claude/`, `.agents/`, `.github/`, `plugins/brain-flows/`)
- [x] `executing-plan/SKILL.md` despacha partes marcadas como delegáveis a subagentes, exige evidências no retorno e define fallback para plataformas sem subagentes — em redação neutra entre plataformas
- [x] Critérios de delegação existem em um único lugar canônico (o reference); os dois `SKILL.md` só apontam
- [x] Versão `1.9.0` idêntica nos dois `plugin.json` e entrada correspondente no `CHANGELOG.md`
- [x] `claude plugin validate` passa nos dois alvos (ou pendência registrada para o usuário)
- [x] `docs/flow/project-structure.md` reflete o novo comportamento, com `related_plans` apontando para este plano

## Riscos e Mitigações

| Risco | Probabilidade | Mitigação |
|-------|--------------|-----------|
| Instrução de despacho assumir capacidade exclusiva de uma plataforma (ferramenta de subagente, modelo, permissão) | Média | Redação neutra exigida como passo explícito da Fase 3; fallback obrigatório torna a delegação opcional |
| Subagente marcar checkboxes sem evidência real | Média | Orquestrador confere as saídas das verificações antes de marcar o status da parte no índice (passo explícito da Fase 3) |
| Espelhos divergirem (editar só um diretório) | Baixa | Fase 4 com `rsync` para os quatro destinos e `diff -r` vazio como verificação |

## Rollback

Todas as mudanças são em arquivos versionados: `git checkout -- .claude/skills/ plugins/ .agents/skills/ .github/skills/ CHANGELOG.md docs/flow/project-structure.md` antes do commit, ou `git revert` do commit da feature depois dele.
