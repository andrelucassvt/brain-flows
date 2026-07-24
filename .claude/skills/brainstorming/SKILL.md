---
name: brainstorming
description: You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation.
---

# Brainstorming

Explora intenção e design antes de qualquer implementação e encerra com um design aprovado + um bloco **Handoff** que o `writing-plan` consome. Não escreve código nem gera o plano.

**Entrada:** o pedido do usuário — primeiro elo da cadeia, não depende de artefato anterior. **Saída:** design aprovado + bloco **Handoff para o Plano** (Fase 4), que sobrevive à compactação de contexto entre as skills.

---

## Fase 0 — Vale brainstorming?

Siga o fluxo completo quando houver criação ou decisão de comportamento, experiência, arquitetura, regra de negócio ou interação entre componentes.

Dispense quando a mudança for puramente mecânica, sem decisão de design: typo ou texto sem mudança de significado, rename direto sem alteração de contrato, formatação/lint/organização de imports, ajuste de constante ou config com valor já definido pelo usuário, correção isolada cuja solução já está determinada. Nesse caso, registre em uma frase por que não há design a decidir e libere a execução direta. Se surgir qualquer escolha com impacto observável, volte ao fluxo completo.

---

## Fase 1 — Intenção e contexto

Primeiro fixe **o quê** o usuário quer, **por quê**, **onde** (features, telas e camadas afetadas) e **qual o impacto** no comportamento atual. Se o pedido for ambíguo, faça **uma pergunta de clarificação por vez**, começando pela que mais altera o design; não pergunte o que dá para inferir com segurança do código; pare quando houver contexto para comparar abordagens.

Depois reúna o contexto já existente:

- **Flows**: rode `grep -n '\*\*Resumo:\*\*' docs/flow/*.md` para ver nome + resumo de **todos** os flows de uma vez e escolher por **relevância semântica** — não só por correspondência de nome — quais abrir por completo (use `project-structure.md` para o geral). Leia integralmente só os relevantes, aproveitando arquivos envolvidos, ordem de execução, regras de negócio, pontos frágeis e dependências. Se o `grep` não retornar nada (flows sem a linha de resumo), caia para `ls ./docs/flow/` e selecione pelo nome. Sem pasta ou flows: siga sem contexto documental e sugira `flow-init` no briefing, sem bloquear.
- **Skill `*-expert`** da stack: procure candidatos `*-expert` em **uma única fonte** — o catálogo de skills da plataforma, ou a raiz nativa (`.claude/skills` no Claude Code, `.agents/skills` no Codex), usando a outra raiz apenas como fallback; nunca agregue as duas. Se achar, leia só o `SKILL.md` (nunca os `references/`) e extraia stack, arquitetura proposta e a tabela de "quando ler cada referência". A brainstorming **referencia** a expert — não invoca, não copia código. Se não achar, use só o arquivo nativo de instruções (`CLAUDE.md` no Claude Code, `AGENTS.md` no Codex).

---

## Fase 2 — Briefing

Sintetize o contexto — não repita os flows palavra por palavra. Inclua apenas as seções com conteúdo real:

```
## Entendimento do Pedido
[Uma frase descrevendo o que precisa ser feito.]

## O que já existe
[2–4 frases sobre como a feature funciona hoje, com base nos flows.
Sem flows: "Nenhuma documentação disponível — análise baseada no código."]

## Pontos de Atenção
[Conflitos, regras de negócio afetadas, dependências surpresa, avisos das Observações dos flows.
Inclua qualquer API/widget/pacote/padrão deprecated que o pedido envolva, com o substituto correto. Omita se vazio.]

## Boas Práticas Disponíveis
[Só se houver skill *-expert: `<nome-expert>` (stack) + referências relevantes ao pedido.
Consulte esta skill antes de implementar para não violar a arquitetura de referência.]

## Próximos Passos Sugeridos
[Ex: "Invoque `writing-plan` para montar o plano, consultando `<nome-expert>`"
ou "Feature simples — pode implementar diretamente seguindo as instruções do projeto e `<nome-expert>`".]
```

Se o pedido for pequeno e claro (uma única feature, sem conflitos aparentes), reduza a **Entendimento do Pedido**, **Pontos de Atenção** e **Próximos Passos Sugeridos**.

---

## Fase 3 — Alternativas e design

Há **decisão real** quando duas abordagens plausíveis mudam responsabilidades, dependências, experiência do usuário, custo de manutenção, risco ou testabilidade.

- **Com decisão real:** apresente 2–3 alternativas com vantagens, desvantagens e impactos concretos no projeto; recomende uma e explique por que ela equilibra melhor requisitos e contexto.
- **Caminho direto:** não invente alternativas artificiais; diga por que a abordagem é determinada pelo padrão existente ou pelo pedido e apresente só o design recomendado.

O design é proporcional à mudança — cubra apenas o relevante: componentes/camadas e responsabilidades, fluxo de dados ou interação, erros e casos limite, verificação/testes quando houver comportamento testável, flows afetados. Mudança pequena: poucos parágrafos. Mudança ampla: apresente em partes coesas, confirmando entendimento entre elas em vez de despejar tudo de uma vez.

```markdown
## Alternativas Consideradas
### Opção A — [nome] · Vantagens / Desvantagens
### Opção B — [nome] · Vantagens / Desvantagens

## Recomendação
[Opção preferida e motivo baseado no contexto do projeto.]

## Design Proposto
- Componentes e responsabilidades · Fluxo de dados/interação · Erros e casos limite · Verificação · Flows afetados
```

---

## Fase 4 — Aprovação e handoff

Peça **aprovação explícita** do design antes de criar um plano ou implementar. Se o usuário pedir ajustes, revise só as partes afetadas e reconfirme. Aprovação de design **não** autoriza alterar código.

Após a aprovação:

- Mudança com múltiplas etapas → recomende ou use `writing-plan` para gerar o plano e entregue o **Handoff** abaixo.
- Mudança pequena e direta → informe que pode seguir direto à implementação, se o usuário preferir; o handoff é dispensável.

### Handoff para o Plano

Interface com o `writing-plan`: ele copia este bloco para a seção **Design de Origem** do plano, tornando-o auto-contido. Preencha só o que se aplica:

```markdown
## Handoff para o Plano
- **Decisão aprovada:** [opção escolhida em uma frase]
- **Alternativas descartadas:** [opção + motivo curto, ou "nenhuma — caminho direto"]
- **Tipo de mudança:** UI-only | Logic
  <!-- UI-only: só View/layout/estilo/rota sem lógica nova, textos, assets.
       Logic: toca estado/domínio/serviço/repositório/datasource/HTTP/banco.
       Você acabou de desenhar a solução — decida aqui, não deixe o writing-plan re-derivar. -->
- **Arquivos-chave:** [caminhos reais citados no design]
- **Skill expert:** `<nome-expert>` + referências relevantes, ou "nenhuma encontrada"
- **Flows a revisitar após implementação:** `docs/flow/<nome>.md` — [seções], ou "nenhum"
```

**Tipo de mudança** é a única classificação de TDD da cadeia — o `writing-plan` a reutiliza em vez de reclassificar. A atualização final dos flows pertence à execução (`executing-plan`), não ao brainstorming.

---

## Regras Gerais

- **Seja preciso** — cite apenas arquivos que você encontrou nos flows ou no código; não invente caminhos.
- **Não bloqueie** — sem flows, o briefing ainda vale (intenção + próximo passo). Nunca impeça o trabalho por falta de documentação.
- **Idioma** — use o mesmo idioma da conversa.
- **Nada deprecated** — nunca indique API/widget/pacote/padrão deprecated na versão atual da stack (ex: `withOpacity`, `WillPopScope` em Flutter); aponte o substituto nos Pontos de Atenção.
