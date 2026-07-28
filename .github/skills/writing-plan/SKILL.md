---
name: writing-plan
description: Gera um plano de implementação estruturado em Markdown e salva em ./docs/plan/. Use quando o usuário pedir para criar, escrever ou gerar um plano ("crie um plano", "escreva um plano", "planeje essa feature", "create a plan", "how should I approach X") ou descrever uma feature, refactor ou implementação de várias etapas que queira planejada antes de codar.
---

# Writing Plan

## O que esta skill faz

Gera um plano estruturado em Markdown e salva em `./docs/plan/<nome-do-plano>.md` (cria a pasta se não existir): objetivo claro, o design de origem, fases com checkboxes, passos acionáveis, verificações e critérios de sucesso.

### Entrada esperada

O ideal é o **Handoff para o Plano** produzido pelo `brainstorming` (decisão aprovada, alternativas descartadas, tipo de mudança, arquivos-chave, skill expert, flows a revisitar). O plano também pode nascer direto de um pedido do usuário, sem brainstorming prévio — nesse caso esta skill reconstrói o mínimo necessário.

### Saída (Handoff)

Um arquivo de plano auto-contido — inclui a seção **Design de Origem**, para que o `executing-plan` execute e defenda a intenção original sem depender do histórico de conversa.

### Referências

Resolvidas a partir do diretório desta skill. Leia cada uma no momento indicado, não antes:

| Arquivo | Quando ler |
|---------|-----------|
| `references/plan-template.md` | No passo 4, antes de escrever o arquivo — estrutura obrigatória e os dois templates de fases |
| `references/multi-part-plan.md` | No passo 2.7, quando a estimativa passar do teto de fases — estrutura da pasta, do índice e das partes |
| `references/headless-testing.md` | No passo 1.5, ao classificar uma mudança UI-only e decidir se a stack suporta teste de componente headless |

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
→ Leia `references/headless-testing.md` e inspecione as dependências do projeto. Se a stack tiver teste de componente headless, inclua uma fase de teste de componente **depois** de construir a UI; se não tiver, não inclua fases de teste.

**Logic** — envolve camada de estado/domínio (ViewModels, Cubits, Controllers, Stores…), serviços de negócio ou sistema, interfaces/implementações de Repository, DataSources, clientes HTTP ou acesso a banco.
→ **Aplique TDD: a fase de testes vem ANTES da implementação da lógica.** Os testes definem o contrato; a implementação os faz passar.

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

### 2.7. Estimar o tamanho e decidir o formato

Com o rascunho das fases em mente, estime o total. **Se passar de 6 fases, o plano vira multi-parte:** leia `references/multi-part-plan.md` e gere uma pasta `docs/plan/<nome>/` com um `00-indice.md` (visão geral, Design de Origem, ordem e dependências) e uma parte numerada por entrega fechada (`01-...md`, `02-...md`), cada uma um plano completo de até ~6 fases no formato normal. O plano completo fica pronto de uma vez — a divisão existe para a execução acontecer em sessões curtas com checkpoint natural entre partes (commit + validação), não para adiar detalhamento.

**Até 6 fases, siga com arquivo único** — não divida plano pequeno.

### 3. Criar o arquivo

Derive um nome `kebab-case` conciso do objetivo (ex: "plano para tela de login" → `login-screen.md`; "refatorar repositório de usuário" → `refactor-user-repository.md`) e salve em `./docs/plan/` (`mkdir -p ./docs/plan`). No modo multi-parte, o nome vira a pasta e cada parte recebe prefixo numérico (`mkdir -p ./docs/plan/<nome>`).

### 4. Escrever o plano

Leia `references/plan-template.md` e siga a estrutura obrigatória, escolhendo o template de fases correspondente ao tipo de mudança classificado no passo 1.5. No modo multi-parte, escreva o índice e cada parte conforme `references/multi-part-plan.md` — todas as partes são escritas agora, com detalhe completo.

---

## Regras de Qualidade

**Passos acionáveis** — cada checkbox deve ser executável sem ambiguidade. Ruim: "adicionar validação". Bom: "adicionar validação de email em `src/features/login/components/EmailField.tsx`".

**Sem placeholders vagos** — nunca "TBD" ou "ver depois". Se não souber, diga o que precisa ser investigado e por quê.

**Fases sequenciais e seguras** — cada fase deve poder ser concluída e verificada antes da próxima. Mudanças de tipos/interfaces vêm antes de implementações.

**Tamanho das fases** — 3–7 passos por fase; se ficar grande, divida.

**Teto de fases por plano** — um plano executável tem no máximo ~6 fases. Escopo maior não vira um monólito de 10+ fases: vira plano multi-parte (passo 2.7), com o detalhe completo distribuído em partes numeradas.

**Riscos obrigatórios para planos com 3+ fases** — liste pelo menos um risco real.

**Verificação nunca executa o app** — nenhum passo pode subir app, emulador, simulador, device, browser real ou suíte E2E/instrumentada. Testar componente no harness não é rodar o app; os limites estão em `references/headless-testing.md`.

---

## Após salvar o arquivo

Informe o usuário: o caminho do arquivo gerado (ou da pasta, no modo multi-parte, listando as partes), um resumo de 2–3 linhas (quantas fases/partes, escopo geral) e pergunte se quer ajustar algo antes da execução. Não execute o plano automaticamente — a decisão de começar é do usuário.

Quando o usuário aprovar a execução, use `executing-plan`. Essa skill é responsável por revisar o plano contra o repositório atual, retomar pelo primeiro checkbox pendente, executar e verificar cada tarefa, registrar o progresso e atualizar os flows afetados.
