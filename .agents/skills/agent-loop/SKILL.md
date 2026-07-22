---
name: agent-loop
description: Orquestra a cadeia completa brainstorming → writing-plan → executing-plan em sequência automática, sem pausar entre writing-plan e executing-plan. Use SOMENTE quando o usuário pedir explicitamente autonomia total pelo ciclo inteiro, com frases como "modo agente autônomo", "rode o fluxo inteiro sem parar", "agent loop", "brainstorme, planeje e implemente sem me perguntar de novo depois que eu aprovar o design", ou peça para explorar, planejar e implementar em um único pedido sem pausas intermediárias. Não ative para pedidos comuns de brainstorming, plano ou execução isolados — nesses casos as pausas normais de cada skill devem ocorrer.
---

# Agent Loop

## O que esta skill faz

Orquestra a cadeia já existente `brainstorming → writing-plan → executing-plan` sem alterar o comportamento interno de nenhuma delas. A única diferença em relação ao uso normal é que, depois que o usuário aprova o design, a skill não pausa mais entre `writing-plan` e `executing-plan` — ela invoca `executing-plan` diretamente assim que o plano é salvo.

Esta skill não substitui nem duplica a lógica das três skills orquestradas. Ela apenas decide a ordem de invocação e informa qual pausa pular.

### Entrada esperada

Um pedido do usuário que peça explicitamente o ciclo completo sem pausas intermediárias. Sem esse pedido explícito, não use esta skill — encaminhe para `brainstorming` normalmente.

### Saída (Handoff)

O mesmo resultado final de `executing-plan`: código implementado e verificado, plano com progresso marcado, e flows estruturalmente afetados atualizados.

---

## Quando usar

Use apenas quando o pedido deixar clara a intenção de rodar o ciclo inteiro sem pausas após a aprovação do design. Se houver dúvida sobre se o usuário quer esse modo, pergunte antes de assumir — acionar este modo por engano pula uma pausa que o usuário talvez esperasse.

Para qualquer outro pedido — mesmo que mencione brainstorming, plano ou execução — use as skills `brainstorming`, `writing-plan` e `executing-plan` diretamente, com suas pausas normais.

---

## Fluxo de execução

### 1. Invocar `brainstorming`

Invoque `brainstorming` com o pedido do usuário, exatamente como seria feito fora deste modo. Nenhuma fase do brainstorming muda.

### 2. Parar no gate de aprovação do design

A Fase 5 do `brainstorming` (aprovação explícita do design) é o único checkpoint humano obrigatório desta cadeia. Nunca pule essa pausa, mesmo em modo autônomo — é o ponto que o usuário decidiu manter como controle humano.

### 3. Invocar `writing-plan` após a aprovação

Assim que o design for aprovado, invoque `writing-plan` com o Handoff produzido pelo `brainstorming`. Nenhuma fase do `writing-plan` muda.

### 4. Pular a pausa final do `writing-plan` e invocar `executing-plan`

Quando `writing-plan` salvar o arquivo do plano, não faça a pergunta "quer ajustar algo antes da execução?". Em vez disso, invoque `executing-plan` imediatamente, na mesma resposta, usando o plano recém-criado.

### 5. Não suprimir os bloqueios de segurança do `executing-plan`

Os pontos de parada nativos do `executing-plan` continuam ativos e não são deste modo desativáveis: drift que contraria o Design de Origem, falta de informação, falta de autoridade ou de dependência externa. Se `executing-plan` parar por um desses motivos, repasse o bloqueio ao usuário normalmente — o loop autônomo não é licença para forçar a execução além do que a skill considera seguro.

### 6. Entregar o resumo final

Ao concluir, informe exatamente o que `executing-plan` reporta ao finalizar: caminho do plano, tarefas e arquivos concluídos, verificações rodadas, flows atualizados e pendências, se houver.

---

## Regras gerais

**Não duplique lógica** — esta skill não reimplementa briefing, comparação de alternativas, template de plano ou execução de tarefas; isso pertence a `brainstorming`, `writing-plan` e `executing-plan`.

**Interrupção a qualquer momento** — se o usuário pedir para parar o loop em qualquer ponto, pare imediatamente e devolva o controle antes de continuar para a próxima skill.

**Um único gate** — a aprovação do design é a única pausa humana obrigatória. Não a remova nem a substitua por uma suposição de aprovação implícita.

**Idioma** — use o mesmo idioma da conversa.
