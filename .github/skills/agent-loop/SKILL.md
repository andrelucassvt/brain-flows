---
name: agent-loop
description: Orquestra a cadeia completa brainstorming → writing-plan → executing-plan de ponta a ponta sem NENHUMA pausa de aprovação humana — inclusive a escolha do design é feita pelo próprio agente. Use SOMENTE quando o usuário pedir explicitamente autonomia total, com frases como "modo agente autônomo", "não quero aceitação humana", "escolha você mesmo o melhor design", "total autonomia", "não pare para me perguntar nada", "implemente sem interrupções até concluir", ou peça para explorar, planejar e implementar em um único pedido sem nenhuma pausa, nem para aprovar o design. Não ative para pedidos comuns de brainstorming, plano ou execução isolados, nem quando o usuário pedir só para pular a pausa entre plano e execução mantendo a aprovação do design — nesses casos use as três skills diretamente, com suas pausas normais.
---

# Agent Loop

## O que esta skill faz

Orquestra a cadeia já existente `brainstorming → writing-plan → executing-plan` do início ao fim sem parar em nenhum ponto para aprovação humana — nem no design, nem no plano, nem na execução. O próprio agente decide a melhor alternativa de design quando há mais de uma plausível, documenta o motivo da escolha e segue implementando até concluir ou até esbarrar num limite real de capacidade.

Esta skill não substitui nem duplica a lógica das três skills orquestradas — ela decide a ordem de invocação e remove todos os pontos de pausa que, no uso normal, esperariam confirmação do usuário.

### Entrada esperada

Um pedido do usuário que peça explicitamente autonomia total pelo ciclo inteiro, sem nenhuma aprovação intermediária. Sem esse pedido explícito, não use esta skill.

### Saída (Handoff)

O mesmo resultado final de `executing-plan`: código implementado e verificado, plano com progresso marcado, e flows estruturalmente afetados atualizados — entregue de uma vez, sem checkpoints no meio do caminho.

---

## Quando usar

Use apenas quando o pedido deixar claro que o usuário não quer ser consultado em nenhuma etapa, nem mesmo para aprovar o design. Se o pedido só quiser pular a pausa entre plano e execução mas manter a aprovação do design, isso não é este modo — é o fluxo normal de `brainstorming` + `writing-plan` + `executing-plan`.

Para qualquer outro pedido, use `brainstorming`, `writing-plan` e `executing-plan` diretamente, com suas pausas normais.

---

## Fluxo de execução

### 1. Invocar `brainstorming` sem esperar aprovação

Invoque `brainstorming` com o pedido do usuário. Percorra normalmente a classificação da mudança, a leitura de flows e a comparação de alternativas quando houver decisão real. Ao chegar na Fase 5 (que normalmente pede aprovação explícita), não pergunte nada: escolha a alternativa recomendada, registre em uma frase o motivo da escolha e monte o próprio bloco de Handoff como se a aprovação tivesse ocorrido.

### 2. Invocar `writing-plan` imediatamente

Assim que o design estiver decidido, invoque `writing-plan` com esse Handoff, na mesma resposta — sem pausa entre brainstorming e writing-plan.

### 3. Invocar `executing-plan` imediatamente

Quando `writing-plan` salvar o arquivo do plano, não faça a pergunta "quer ajustar algo antes da execução?". Invoque `executing-plan` imediatamente, usando o plano recém-criado.

### 4. Seguir até concluir, sem parar por confirmação

Execute todas as fases do plano em sequência, uma tarefa por vez, sem pausar para pedir permissão de continuar entre tarefas ou fases. Tome a decisão mais razoável diante de ambiguidades menores (nome de arquivo, pequeno detalhe não especificado) e documente a escolha em vez de perguntar.

Limites reais de capacidade continuam existindo e não são pontos de aprovação a serem contornados: falta de uma credencial ou dependência externa que não pode ser criada, ou uma ambiguidade sem nenhuma opção segura padrão. Nesses casos, escolha o caminho mais razoável disponível e prossiga; só relate a limitação no resumo final em vez de interromper o fluxo para perguntar.

Esta skill não controla prompts de permissão de ferramentas (Bash e outras) impostos pelo ambiente do usuário — esses são configurados fora do conteúdo desta skill. O que a skill garante é não introduzir nenhuma pergunta própria de confirmação em nenhuma etapa do ciclo.

### 5. Entregar o resultado final de uma vez

Ao concluir, entregue o resumo final (caminho do plano, tarefas e arquivos concluídos, verificações rodadas, flows atualizados) em uma única resposta — sem ter parado em nenhum checkpoint anterior para pedir aprovação.

---

## Regras gerais

**Não duplique lógica** — esta skill não reimplementa briefing, comparação de alternativas, template de plano ou execução de tarefas; isso pertence a `brainstorming`, `writing-plan` e `executing-plan`. O que muda é só a ausência de pausas.

**Decisão documentada, não perguntada** — toda escolha que normalmente seria levada ao usuário (design, ajustes no plano, início da execução) é feita pelo próprio agente e registrada com uma frase de justificativa, nunca perguntada.

**Interrupção a pedido do usuário** — se o usuário pedir para parar o loop a qualquer momento durante a execução, pare imediatamente.

**Idioma** — use o mesmo idioma da conversa.
