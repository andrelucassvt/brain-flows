---
name: writing-plan
description: Generates a structured Markdown implementation plan and saves it to the /docs/plan folder. Use when the user asks to "create a plan", "write a plan", "plan this feature", "gerar um plano", "criar um plano", "escrever um plano", "how should I approach X", or describes any multi-step feature, refactor, or implementation they want planned before coding.
---

# Writing Plan

## O que esta skill faz

Gera um plano estruturado em Markdown e salva em `./docs/plan/<nome-do-plano>.md` (cria a pasta se não existir): objetivo claro, o design de origem, fases com checkboxes, passos acionáveis, verificações e critérios de sucesso.

### Entrada esperada

O ideal é o **Handoff para o Plano** produzido pelo `brainstorming` (decisão aprovada, alternativas descartadas, tipo de mudança, arquivos-chave, skill expert, flows a revisitar). O plano também pode nascer direto de um pedido do usuário, sem brainstorming prévio — nesse caso esta skill reconstrói o mínimo necessário.

### Saída (Handoff)

Um arquivo de plano auto-contido — inclui a seção **Design de Origem**, para que o `executing-plan` execute e defenda a intenção original sem depender do histórico de conversa.

---

## Fluxo de Execução

### 0. Absorver o Handoff do brainstorming

**Se o `brainstorming` rodou e entregou o bloco Handoff:** use-o como fonte. Copie decisão, alternativas descartadas, tipo de mudança, arquivos-chave e flows para o plano — não reabra decisões já aprovadas nem reclassifique o tipo de mudança.

**Se não houver handoff** (plano pedido direto, ou brainstorming perdido na compactação de contexto): reconstrua uma decisão de design em uma ou duas frases a partir do pedido e do código. Se a mudança tiver decisão de design real e ambígua, prefira sugerir o `brainstorming` antes de planejar, em vez de inventar a decisão silenciosamente.

### 1. Entender o contexto

Responda mentalmente: **o que** precisa ser feito, **por quê**, **quais arquivos/sistemas** estão envolvidos e **qual o critério de conclusão**.

Se o prompt for vago e não houver handoff, faça **uma única pergunta de clarificação** — a mais importante.

### 1.5. Classificar o tipo de mudança

**Se o Handoff já trouxe o `Tipo de mudança`, use-o** — não reclassifique. Só reavalie se o código contradisser claramente a classificação recebida (ex.: o handoff diz UI-only mas o design exige um novo Repository); nesse caso, ajuste e registre o motivo em uma frase.

Sem handoff, classifique agora:

**UI-only** — apenas estrutura visual de Views (layout, componentes, estilos, animações), extração de componentes de UI, ajustes de rota sem lógica nova, textos/traduções/assets.
→ Se a stack tiver **teste de componente headless** (ver abaixo), inclua uma fase de teste de componente **depois** de construir a UI. Se não tiver, não inclua fases de teste.

**Logic** — envolve camada de estado/domínio (ViewModels, Cubits, Controllers, Stores…), serviços de negócio ou sistema, interfaces/implementações de Repository, DataSources, clientes HTTP ou acesso a banco.
→ **Aplique TDD: a fase de testes vem ANTES da implementação da lógica.** Os testes definem o contrato; a implementação os faz passar.

#### Teste de componente headless ≠ rodar o app

"Rodar o app" (proibido) é subir emulador, simulador, dispositivo, browser real ou suíte E2E/instrumentada e interagir manualmente. **Teste de componente headless** monta a árvore de UI no test harness da própria stack, sem device — é permitido e desejado, porque valida render e interação sem executar o app.

Antes de escrever o plano, **inspecione as dependências do projeto** (`pubspec.yaml`, `package.json`, `build.gradle`, `Package.swift`…) e só adicione a fase de teste de componente se houver um framework de teste headless de UI:

| Stack | Teste de componente headless (usar) | Exige device (NÃO usar aqui) |
|-------|-------------------------------------|------------------------------|
| Flutter | `flutter test` — widget tests (`testWidgets`, `WidgetTester`) | `integration_test` |
| React / React Native | Testing Library + Jest/Vitest (jsdom) | Detox, Cypress/Playwright |
| Vue | Vue Test Utils + Vitest/Jest | Cypress/Playwright |
| Angular | TestBed + Jest/Karma | Protractor, Cypress |
| Android nativo | Compose + Robolectric (`createComposeRule`) | `androidTest` / Espresso |
| SwiftUI | ViewInspector / snapshot tests | XCUITest |

Se a stack não tiver framework de teste headless de UI, ou você não conseguir confirmá-lo pelas dependências, trate como UI-only sem testes — nunca rode o app para compensar a ausência de testes.

### 2. Verificar flows existentes

```bash
ls ./docs/flow/ 2>/dev/null
```

**Se o brainstorming já rodou nesta conversa e leu os flows relevantes** (o Handoff lista os "flows a revisitar"), reutilize esse conteúdo do contexto — não releia os arquivos. Registre esses flows no cabeçalho **Flows relacionados** do plano.

**Se existir flow relacionado ainda não lido:** leia-o e use arquivos envolvidos, ordem de execução e regras de negócio para preencher o plano com caminhos reais. Se o plano envolver mudanças **estruturais** (novos arquivos, camadas renomeadas, responsabilidade movida), adicione uma fase final **"Atualizar Flow"** com os passos concretos do que atualizar em `./docs/flow/<nome>.md`. Mudança interna sem impacto estrutural não precisa dessa fase.

**Se não existir flow relacionado:** siga com o plano e adicione ao final (fora das fases):

```markdown
## Após a Implementação

> Perguntar ao usuário: "Deseja criar um flow dessa funcionalidade em `./docs/flow/`? Ele documenta o caminho completo do fluxo e serve de referência para futuros planos e revisões."
```

Essa pergunta deve **sempre** ser feita quando não há flow — nunca assuma que o usuário não quer.

### 2.5. Revisão de simplicidade

Antes de escrever as fases, revise o rascunho da tabela de Arquitetura/Escopo com a pergunta: **essa complexidade é exigida pelo problema, ou é só a primeira solução que veio à mente?**

- Cada arquivo novo ou camada extra precisa de razão concreta (regra de negócio, separação já usada no projeto, requisito explícito do usuário)
- Prefira a menor mudança que resolve o problema real; não crie abstrações "para o futuro" — isso é over-engineering, não planejamento
- Se o escopo encolher nessa revisão, é o resultado esperado. Se genuinamente precisa de vários arquivos/fases, mantenha — a revisão é contra inchaço injustificado, não contra complexidade real.

### 3. Criar o arquivo

Derive um nome `kebab-case` conciso do objetivo (ex: "plano para tela de login" → `login-screen.md`; "refatorar repositório de usuário" → `refactor-user-repository.md`) e salve em `./docs/plan/` (`mkdir -p ./docs/plan`).

### 4. Escrever o plano usando a estrutura abaixo

---

## Estrutura do Plano (template obrigatório)

```markdown
# [Título do Plano]

> **Objetivo:** Uma frase descrevendo o que será entregue ao final.
> **Design de origem:** brainstorming desta conversa | reconstruído a partir do pedido
> **Flows relacionados:** `docs/flow/<nome>.md`, ... (ou "nenhum")

## Contexto

[2–4 frases explicando o estado atual, o problema ou a motivação.]

## Design de Origem

<!--
  Copie aqui o Handoff do brainstorming (decisão + alternativas descartadas).
  Sem handoff, escreva a decisão de design em 1–2 frases.
  Esta seção é o que o executing-plan consulta para defender a intenção original
  ao lidar com drift — não a omita.
-->

- **Decisão aprovada:** [opção escolhida em uma frase]
- **Alternativas descartadas:** [opção + motivo, ou "nenhuma — caminho direto"]
- **Tipo de mudança:** UI-only | Logic

## Arquitetura / Escopo

[Tabela mapeando os arquivos/módulos afetados. Inclua apenas o que muda ou é criado.]

| Arquivo | Ação | Responsabilidade |
|---------|------|-----------------|
| `<caminho>` | criar | ... |

## Fases

<!--
  Mudança UI-only → template A (fase de teste de componente ao final SE a stack tiver teste headless de UI; senão, sem testes)
  Mudança Logic (estado/serviço/repositório/datasource) → template B (TDD: testes antes)
  Remova este comentário e o template que não se aplica antes de salvar.
-->

<!-- TEMPLATE A — UI-only -->
### Fase 1 — [Nome da Fase de UI]

- [ ] Passo 1: [ação concreta com arquivo e componente]
- [ ] Passo 2: ...
- [ ] Verificação: [checagem sem executar o app — ex: análise estática limpa, componente presente no arquivo]

_(repita para cada fase de UI)_

<!--
  Inclua a fase abaixo SOMENTE se a stack tiver teste de componente headless (ver 1.5).
  Ela vem DEPOIS de o componente existir. Se a stack não tiver, remova esta fase.
-->
### Fase N — Teste de componente (após a UI existir)

- [ ] Criar `<caminho>/test/<componente>_test.<ext>` (widget/component test da stack)
- [ ] Testar que o componente renderiza os elementos-chave (texto, ícone, campo)
- [ ] Testar interação no harness: tap / entrada de texto → callback disparado ou estado visual muda
- [ ] Testar variação de estado visual relevante (vazio, erro, selecionado) quando aplicável
- [ ] Verificação: `<comando de teste da stack>` passa sem subir app/emulador/device

---

<!-- TEMPLATE B — Logic (TDD: testes primeiro) -->
### Fase 1 — Testes (contrato antes da implementação)

> Os testes vão falhar inicialmente — isso é intencional.

- [ ] Criar `<caminho>/test/<arquivo>.test.<ext>`
- [ ] Testar caso de sucesso: [descrição]
- [ ] Testar caso de erro/falha: [descrição]
- [ ] Testar estado de loading (quando aplicável)
- [ ] Verificação: testes compilam e falham pelos motivos certos (não por erro de sintaxe)

### Fase 2 — Implementação (fazer os testes passarem)

- [ ] Implementar [ViewModel / Service / Repository / DataSource] em `<caminho>`
- [ ] Registrar no container de DI se necessário
- [ ] Verificação: testes passam sem erros

### Fase 3 — UI (se houver interface para a lógica implementada)

- [ ] Conectar View à camada de estado
- [ ] Verificação: análise/build limpos — o teste do fluxo de ponta a ponta é manual, do usuário

_(repita fases de implementação/UI conforme necessário)_

## Critérios de Sucesso

- [ ] [resultado observável 1]
- [ ] [resultado observável 2]
- [ ] Build sem erros
- [ ] _(somente para mudanças Logic)_ Todos os testes unitários passando
- [ ] _(quando houver fase de teste de componente)_ Testes de componente/widget passando no harness
- [ ] _(manual — feito pelo usuário)_ Validação funcional no app

## Riscos e Mitigações

| Risco | Probabilidade | Mitigação |
|-------|--------------|-----------|
| ... | Baixa/Média/Alta | ... |

## Rollback

[Como desfazer as mudanças se algo der errado. Se não aplicável, escreva "N/A".]
```

---

## Regras de Qualidade

**Passos acionáveis** — cada checkbox deve ser executável sem ambiguidade. Ruim: "adicionar validação". Bom: "adicionar validação de email em `src/features/login/components/EmailField.tsx`".

**Sem placeholders vagos** — nunca "TBD" ou "ver depois". Se não souber, diga o que precisa ser investigado e por quê.

**Fases sequenciais e seguras** — cada fase deve poder ser concluída e verificada antes da próxima. Mudanças de tipos/interfaces vêm antes de implementações.

**Tamanho das fases** — 3–7 passos por fase; se ficar grande, divida.

**Riscos obrigatórios para planos com 3+ fases** — liste pelo menos um risco real.

**Verificação nunca executa o app, mas testa componentes no harness** — nenhum passo pode subir o app (emulador, simulador, dispositivo, browser real, `flutter run` ou suíte E2E/instrumentada da stack), tirar screenshots ou simular interação manual. Verificações se limitam a análise estática, build e **testes que rodam no test harness** — unitários e de componente/widget headless (ex: `flutter test`, Testing Library). Montar e testar um componente no harness NÃO é rodar o app, e é a forma preferida de validar UI quando a stack suporta. O teste funcional/visual de ponta a ponta continua sendo do usuário, feito manualmente após a entrega.

---

## Após salvar o arquivo

Informe o usuário: o caminho do arquivo gerado, um resumo de 2–3 linhas (quantas fases, escopo geral) e pergunte se quer ajustar algo antes da execução. Não execute o plano automaticamente — a decisão de começar é do usuário.

Quando o usuário aprovar a execução, use `executing-plan`. Essa skill é responsável por revisar o plano contra o repositório atual, retomar pelo primeiro checkbox pendente, executar e verificar cada tarefa, registrar o progresso e atualizar os flows afetados.
