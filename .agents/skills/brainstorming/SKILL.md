---
name: brainstorming
description: You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation.
---

# Brainstorming

## O que esta skill faz

Camada de inteligência de contexto antes de qualquer implementação:

1. **Classifica a mudança** para não impor design a trabalho puramente mecânico
2. **Explora a intenção** do usuário para garantir entendimento preciso
3. **Lê os flows relevantes** em `./docs/flow/` para entender como o sistema funciona hoje
4. **Detecta a skill `*-expert`** da stack do projeto e aponta as referências relevantes
5. **Compara alternativas reais**, recomenda uma abordagem e apresenta o design
6. **Obtém aprovação** antes de encaminhar a mudança para o planejamento

Esta skill não escreve código nem gera o arquivo de plano. Ela encerra a descoberta com um design aprovado; depois disso, o próximo passo é `writing-plan`.

---

## Fase 0 — Classificar a mudança

Use o fluxo completo somente quando houver criação ou decisão de comportamento, experiência, arquitetura, regra de negócio ou interação entre componentes.

Dispense o brainstorming completo quando a mudança for puramente mecânica e não exigir decisão de design:

- Correção de typo ou texto sem mudança de significado/comportamento
- Rename direto, com referências conhecidas e sem alteração de contrato
- Formatação, lint ou organização mecânica de imports
- Ajuste simples de constante ou configuração com valor já definido pelo usuário
- Correção isolada cuja solução já está determinada e não muda arquitetura nem regra de negócio

Se a skill tiver sido ativada para um caso mecânico, registre em uma frase por que não há decisão de design e libere a execução direta. Se surgir qualquer escolha com impacto observável, siga o fluxo completo.

---

## Fase 1 — Entender a intenção

Antes de buscar qualquer arquivo, fixe: **o quê** o usuário quer criar ou mudar, **por quê**, **onde** (features, telas e camadas afetadas) e **qual o impacto** no comportamento existente.

Se o pedido for ambíguo, faça **uma pergunta de clarificação por vez**, começando pela que mais altera o design. Não pergunte o que você pode inferir com segurança do código e pare de perguntar quando houver contexto suficiente para comparar abordagens.

---

## Fase 2 — Carregar contexto dos flows

```bash
ls ./docs/flow/ 2>/dev/null
```

**Se a pasta não existir ou estiver vazia:** siga para a Fase 2.5 sem contexto documental. No briefing, mencione que não há flows e sugira invocar a skill `flow-init` — mas não bloqueie o trabalho por isso.

**Se existir, faça triagem antes de ler:**

1. Selecione candidatos pelo nome do arquivo, cruzando com as palavras-chave do pedido (ex: "login", "pagamento"); use `project-structure.md` para contexto geral
2. Leia apenas as primeiras ~5 linhas de cada candidato — o `> **Resumo:**` diz do que o flow trata
3. Leia por completo somente os flows que a triagem confirmar relevantes

De cada flow lido, aproveite: arquivos envolvidos, ordem de execução, regras de negócio, observações/pontos frágeis e dependências externas.

---

## Fase 2.5 — Detectar skill de especialista da linguagem

Use uma única fonte de skills por execução:

- Se a plataforma expuser um catálogo de skills, procure `*-expert` somente nele e não varra diretórios locais.
- Sem catálogo, use somente a raiz nativa: `.agents/skills` no Codex ou `.claude/skills` no Claude Code.
- Consulte a raiz da outra plataforma apenas como fallback quando a raiz nativa não existir. Nunca agregue resultados das duas raízes nem leia duas cópias da mesma skill.

Depois de selecionar a fonte, liste apenas os candidatos `*-expert`. Não suponha que um diretório exista.

**Se encontrar** (ex: `flutter-expert`, `spring-expert`): leia apenas o `SKILL.md` de cada uma — **não** leia os arquivos em `references/`, isso é responsabilidade da fase de implementação. Extraia a stack, a arquitetura proposta e a tabela de "quando ler cada referência" (se houver). A brainstorming **identifica e referencia** a skill expert — não invoca, não copia código, não duplica regras.

**Se não encontrar:** omita a seção **Boas Práticas Disponíveis** do briefing e siga com os flows e somente o arquivo de instruções nativo da plataforma (`AGENTS.md` no Codex ou `CLAUDE.md` no Claude Code). Use um equivalente apenas como fallback quando o arquivo nativo não existir; não leia os dois.

---

## Fase 3 — Briefing de contexto

**Pedido simples** (escopo pequeno e claro, uma única feature, sem conflitos aparentes): reduza o briefing a três seções — **Entendimento do Pedido**, **Pontos de Atenção** e **Próximos Passos Sugeridos**.

**Caso contrário**, use o template completo:

```
## Entendimento do Pedido
[Uma frase descrevendo o que precisa ser feito]

## Contexto Carregado
- Flows lidos: [lista, ou "nenhum — ./docs/flow/ não existe"]
- Features afetadas: [lista]
- Arquivos-chave envolvidos: [caminhos reais encontrados nos flows]

## Boas Práticas Disponíveis
[Omita esta seção se nenhuma skill *-expert foi encontrada. Caso contrário:]
- Skill: `<nome-expert>` — stack <linguagem/framework>
- Referências relevantes para este pedido:
  - `references/<arquivo>.md` — [motivo, ex: "criar View"]
- Consulte esta skill antes de implementar para não violar a arquitetura de referência.

## O que já existe
[2–4 frases sobre como a feature funciona hoje, com base nos flows.
Sem flows: "Nenhuma documentação disponível — análise baseada no código."]

## Pontos de Atenção
[Conflitos, regras de negócio afetadas, dependências surpresa, avisos das Observações dos flows.
Inclua qualquer API, widget, pacote ou padrão deprecated que o pedido envolva — com o substituto correto e o motivo. Se não houver nada relevante, omita.]

## Flows a Revisitar Após Implementação
- `docs/flow/<nome>.md` — revisitar se [quais seções podem mudar]
- (ou: "Nenhum — não há flows documentados para as features afetadas")

## Próximos Passos Sugeridos
[Ex: "Invoque a skill `writing-plan` para montar o plano, consultando `<nome-expert>` para os padrões da camada"
ou "Feature simples — pode implementar diretamente seguindo as instruções do projeto e `<nome-expert>`"]
```

O briefing é uma síntese — não repita os flows palavra por palavra.

---

## Fase 4 — Explorar alternativas e propor o design

Depois do briefing, identifique se existe uma decisão real. Há decisão real quando duas abordagens plausíveis mudam responsabilidades, dependências, experiência do usuário, custo de manutenção, risco ou capacidade de teste.

**Quando houver decisão real:** apresente duas ou três alternativas, com vantagens, desvantagens e impactos concretos no projeto. Recomende uma opção e explique por que ela equilibra melhor os requisitos e o contexto encontrado.

**Quando o caminho for direto:** não invente alternativas artificiais. Declare brevemente por que a abordagem é determinada pelo padrão existente ou pelo pedido e apresente somente o design recomendado.

O design deve ser proporcional à mudança. Cubra apenas os tópicos relevantes:

- Componentes, camadas e responsabilidades afetadas
- Fluxo de dados ou sequência de interação
- Estados de erro, fallback e casos limite
- Estratégia de verificação e testes quando houver comportamento testável
- Impactos nos flows existentes

Para mudanças pequenas, poucos parágrafos bastam. Para mudanças amplas, apresente o design em partes coesas e confirme entendimento entre as partes, evitando despejar uma solução extensa de uma vez.

Use esta estrutura como guia, removendo seções que não agregam:

```markdown
## Alternativas Consideradas

### Opção A — [nome]
- Vantagens: ...
- Desvantagens: ...

### Opção B — [nome]
- Vantagens: ...
- Desvantagens: ...

## Recomendação
[Opção preferida e motivo baseado no contexto do projeto.]

## Design Proposto
- Componentes e responsabilidades: ...
- Fluxo de dados/interação: ...
- Erros e casos limite: ...
- Verificação: ...
- Flows afetados: ...
```

---

## Fase 5 — Aprovação e handoff

Peça aprovação explícita do design antes de criar um plano ou iniciar a implementação. Se o usuário pedir ajustes, revise somente as partes afetadas e peça nova confirmação.

Depois da aprovação:

- Para uma mudança com múltiplas etapas, recomende ou use `writing-plan` para gerar o plano executável.
- Se a mudança aprovada for pequena e direta, informe que pode seguir para implementação sem criar um plano, caso o usuário prefira.
- Não implemente automaticamente: a aprovação do design não presume autorização para alterar código.

---

## Responsabilidade após a implementação

A atualização final dos flows pertence à execução da mudança, não ao brainstorming. Quando houver plano, `executing-plan` assume essa responsabilidade com base na seção **Flows afetados** do design e nas tarefas do plano.

---

## Regras Gerais

**Seja preciso** — cite apenas arquivos que você encontrou nos flows ou no código. Não invente caminhos.

**Não bloqueie** — sem flows, o briefing ainda tem valor (intenção + próximo passo). Nunca impeça o trabalho por falta de documentação.

**Idioma** — use o mesmo idioma da conversa com o usuário.

**Nada deprecated** — nunca indique APIs, widgets, pacotes ou padrões deprecated na versão atual da stack (ex: `withOpacity`, `WillPopScope` em Flutter); aponte o substituto correto nos **Pontos de Atenção**. Não sugira versões antigas de pacotes quando existe uma estável mais recente.
