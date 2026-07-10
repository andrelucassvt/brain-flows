---
name: flow
description: Maps a feature or process end-to-end by scanning the current project and generates a Markdown document in ./docs/flow/ describing the full flow — files involved, call order, layer responsibilities, and business rules. Use when the user asks to "create a flow", "map/document the flow of X", "flow do login", "fluxo do checkout", "como funciona o fluxo de X", "mapear como X funciona no projeto", or any request to trace how a feature works from entry point to data layer.
---

# Flow

## O que esta skill faz

Analisa o repositório atual e gera `./docs/flow/<nome-do-fluxo>.md` mapeando de ponta a ponta como um fluxo (feature, processo ou caso de uso) funciona: quais arquivos participam, em que ordem são acionados, qual a responsabilidade de cada camada e quais regras de negócio existem no código. O objetivo é uma fotografia precisa e navegável, suficiente para entender, depurar ou estender a feature sem redescobrir o caminho lendo o código inteiro.

---

## Fluxo de Execução

### 1. Entender qual fluxo mapear

Fixe: **ponto de entrada** (tela, botão, rota, deep link, evento, cron), **resultado final esperado** (navegação, persistência, chamada de API, side effect) e **escopo** (só caminho feliz, ou também erros e edge cases relevantes).

Se o nome do fluxo for ambíguo no contexto do projeto (ex: dois "checkout" diferentes), faça **uma única pergunta de clarificação**. Caso contrário, prossiga.

### 2. Varrer o projeto

Mapeie o código de verdade — não invente arquivos. Comece pelo nome do fluxo como termo de busca (ex: `login`, `checkout`, `createUser`) e siga as referências: do ponto de entrada para baixo (UI → estado → repositório → datasource → API/DB) e dos serviços compartilhados de volta à UI quando relevante (ex: interceptor que injeta token).

Cubra: pontos de entrada (Views, rotas, handlers, listeners), camada de apresentação/orquestração (Cubits, ViewModels, Controllers), domínio (Entities, Use Cases, regras puras), dados (Repositories, DataSources, clientes HTTP, queries), serviços auxiliares (Storage, Auth, Analytics, interceptors), configuração (DI, rotas declaradas) e testes existentes que cobrem o fluxo.

Respeite a nomenclatura real do código — não force o vocabulário de uma arquitetura que o projeto não adota.

### 3. Criar o arquivo

Derive um nome `kebab-case` curto ("flow do login" → `login.md`; "fluxo de pagamento via Pix" → `payment-pix.md`) e salve em `./docs/flow/` (`mkdir -p ./docs/flow`).

Se o arquivo já existir, **não sobrescreva silenciosamente** — informe o usuário e pergunte se deve atualizar (preservando seções customizadas) ou regenerar do zero.

Antes de escrever, registre a rastreabilidade da análise:

```bash
git rev-parse --short HEAD 2>/dev/null
git status --porcelain 2>/dev/null
```

- Em repositório Git, use o hash curto em `source_commit` e `clean`/`dirty` em `source_state`.
- Fora de um repositório Git, use `not-available` nos dois campos.
- Em atualização, preserve o `generated_at` original e renove `verified_at`, `source_commit`, `source_state` e `status`.
- Só use `status: current` depois da autorrevisão da Fase 5. Use `draft` enquanto incompleto, `possibly-stale` se alguma referência não puder ser confirmada e `archived` apenas quando o usuário arquivar o flow.

### 4. Escrever o documento usando a estrutura abaixo

---

## Estrutura do Documento (template obrigatório)

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

---

## Fase 5 — Autorrevisar antes de salvar

Confronte o documento final com o código analisado. Esta revisão é o que permite marcar o flow como `current`:

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

---

## Regras de Qualidade

**Citações reais** — todo arquivo, classe ou método mencionado deve existir no repositório. Se não tem certeza, releia o código antes de escrever.

**Ordem reflete execução** — o "Passo a Passo" segue a ordem real de chamada no runtime, não a ordem de descoberta.

**Vocabulário do projeto** — se o projeto chama de "Cubit", use "Cubit"; se chama de "ViewModel", use "ViewModel". Não traduza nem padronize à força.

**Profundidade adequada** — uma a duas frases por passo: o suficiente para entender o caminho sem abrir cada arquivo, sem colar código inteiro.

**Sem placeholders** — se algo não está claro no código (ex: rota dinâmica), escreva "definido em runtime via X" em vez de "TBD".

**Rastreabilidade honesta** — metadados descrevem o estado realmente analisado. Um commit com alterações locais deve permanecer identificado como `source_state: dirty`.

**Imparcialidade** — documente o que existe; problemas vão em "Observações" de forma factual.

**Idioma** — o mesmo da conversa com o usuário.

---

## Após salvar o arquivo

Informe o caminho gerado, o status de verificação e um resumo de 2–3 linhas (camadas atravessadas, arquivos mapeados, observações relevantes). Pergunte se quer detalhar algum passo ou gerar o flow de outra feature.

Não modifique o código do projeto — esta skill é puramente documental.
