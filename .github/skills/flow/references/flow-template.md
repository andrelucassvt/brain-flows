# Template do documento de flow

Estrutura obrigatória de `./docs/flow/<nome-do-fluxo>.md`, seguida da checklist de autorrevisão que autoriza marcar o flow como `current`.

## Frontmatter

- `source_commit` / `source_state`: hash curto de `git rev-parse --short HEAD` e `clean`/`dirty` conforme `git status --porcelain`. Fora de um repositório Git, use `not-available` nos dois campos.
- Em atualização: preserve o `generated_at` original e renove `verified_at`, `source_commit`, `source_state` e `status`.
- `status`: `current` só depois da autorrevisão abaixo. `draft` enquanto incompleto, `possibly-stale` se alguma referência não puder ser confirmada, `archived` apenas quando o usuário arquivar o flow.

## Estrutura

```markdown
---
generated_at: YYYY-MM-DD
source_commit: abc1234
source_state: clean
verified_at: YYYY-MM-DD
status: current
related_plans: []
---

# Flow: [Nome do Fluxo]

> **Resumo:** Uma frase descrevendo o que esse fluxo faz no produto, da perspectiva do usuário ou do sistema.

## Visão Geral

[2–5 parágrafos explicando o fluxo de ponta a ponta: comece pelo gatilho (ex: "o usuário toca no botão Entrar"), passe pelas camadas envolvidas e termine no efeito final. Mencione decisões importantes — autenticação, validações, side effects, integrações — sem detalhes de implementação.]

## Passo a Passo

Sequência ordenada do gatilho até o resultado final. Cada passo referencia o arquivo/classe/função real do projeto.

1. **[Camada/Componente]** — `caminho/do/arquivo.ext` → `MétodoOuClasse`
   Descrição curta do que acontece neste passo.
2. ...

_(Use sub-itens para ramificações relevantes: erro, cache hit, retry, etc.)_

### Caminhos alternativos

- **Erro de rede:** [o que acontece e em qual arquivo é tratado]
- **Validação falha:** [...]

_(Inclua apenas ramificações que existem de fato no código.)_

## Arquivos Envolvidos

| Camada | Arquivo | Responsabilidade |
|--------|---------|------------------|
| Apresentação | `caminho/arquivo.ext` | O que esse arquivo faz neste fluxo |
| Estado / ViewModel | `caminho/arquivo.ext` | ... |
| Domínio | `caminho/arquivo.ext` | ... |
| Dados | `caminho/arquivo.ext` | ... |
| Serviços | `caminho/arquivo.ext` | ... |
| Configuração | `caminho/arquivo.ext` | ... |
| Testes | `caminho/arquivo.ext` | ... |

## Regras de Negócio Relevantes

Regras encontradas no código que afetam o fluxo (validações, gates, limites, side effects condicionais), com o arquivo onde cada uma mora.

- **[Regra]** — `caminho/arquivo.ext`: explicação curta.

_(Se não houver, escreva "Nenhuma regra de negócio relevante além do controle de fluxo padrão.")_

## Dependências Externas

APIs, SDKs, serviços de terceiros, variáveis de ambiente que o fluxo consome. _(Se não houver, omita esta seção.)_

## Observações

[TODOs encontrados, inconsistências, pontos frágeis, divergências entre o que o código faz e o que o nome sugere. Objetivo, sem opinião gratuita.]
```

## Checklist de autorrevisão

Confronte o documento final com o código analisado antes de salvar:

- Todos os arquivos citados existem?
- Classes, funções e métodos citados foram encontrados nos arquivos indicados?
- O Passo a Passo segue a ordem real de execução?
- Caminhos alternativos e regras de negócio existem de fato no código?
- O documento usa o vocabulário real do projeto?
- Não restaram placeholders ou afirmações sem evidência?
- Em uma atualização, as seções customizadas anteriores foram preservadas?
- `source_commit` e `source_state` correspondem ao estado analisado?
- `related_plans` lista somente planos realmente relacionados, ou permanece `[]`?

Corrija divergências antes de salvar. Se algum item não puder ser confirmado, descreva a limitação em **Observações** e use `status: possibly-stale` em vez de apresentar o documento como atual.
