---
name: agent-loop
description: Orquestra a cadeia completa brainstorming → writing-plan → executing-plan de ponta a ponta sem NENHUMA pausa de aprovação humana — inclusive a escolha do design é feita pelo próprio agente. Use SOMENTE quando o usuário pedir explicitamente autonomia total pelo ciclo inteiro: frases como "modo agente autônomo", "total autonomia", "escolha você mesmo o design", "não pare para me perguntar nada", "implemente sem interrupções até concluir", ou um pedido único para explorar, planejar e implementar sem nenhuma pausa. NÃO invocar para pedidos isolados de brainstorming, plano ou execução, nem quando o usuário só quiser pular a pausa entre plano e execução mantendo a aprovação do design — nesses casos use as três skills diretamente.
permissionMode: bypassPermissions
---

# Agent Loop

Orquestra `brainstorming → writing-plan → executing-plan` do início ao fim sem parar em nenhum ponto para aprovação humana — nem no design, nem no plano, nem na execução. O próprio agente decide a melhor alternativa quando há mais de uma plausível, documenta o motivo em uma frase e segue implementando até concluir ou esbarrar num limite real de capacidade.

Não reimplementa a lógica das três skills — apenas decide a ordem de invocação (via ferramenta Skill) e remove os pontos de pausa que, no uso normal, esperariam confirmação do usuário.

**Entrada:** um pedido que peça explicitamente autonomia total pelo ciclo inteiro.
**Saída (Handoff):** um Pull Request com o resultado de `executing-plan` — código implementado e verificado, plano com progresso marcado, flows afetados atualizados —, commitado numa branch isolada e publicado sem merge automático, entregue de uma vez.

## Autonomia e isolamento

Este agente roda com `permissionMode: bypassPermissions`: todos os prompts de confirmação de ferramentas são pulados automaticamente. Por isso só deve atuar quando o pedido pedir autonomia total de forma explícita — nunca por inferência.

O contrapeso do bypass é o isolamento: **nunca** trabalhe na branch/checkout que o usuário tinha aberto. Todo o ciclo roda dentro de um worktree isolado (`EnterWorktree`) e termina com as mudanças publicadas via Pull Request. Assim, erros ficam contidos numa branch descartável.

---

## Fluxo de execução

**0. Isolar o trabalho.** Antes de qualquer skill, use `EnterWorktree` para criar um worktree dedicado (nome curto em kebab-case derivado do pedido). Todo o trabalho acontece dentro dele.

**1. `brainstorming` sem esperar aprovação.** Invoque a skill com o pedido do usuário e percorra normalmente a classificação da mudança, a leitura de flows e a comparação de alternativas. Ao chegar na Fase 4 (Aprovação e handoff), não pergunte nada: escolha a alternativa recomendada, registre em uma frase o motivo e monte o próprio bloco de Handoff como se a aprovação tivesse ocorrido.

**2. `writing-plan` imediatamente.** Assim que o design estiver decidido, invoque a skill com esse Handoff, na mesma resposta.

**3. `executing-plan` imediatamente.** Quando o plano for salvo, não faça a pergunta "quer ajustar algo antes da execução?". Invoque `executing-plan` na hora, com o plano recém-criado.

**4. Seguir até concluir.** Execute todas as fases em sequência, uma tarefa por vez, sem pausar para pedir permissão entre tarefas ou fases. Diante de ambiguidades menores (nome de arquivo, detalhe não especificado), tome a decisão mais razoável e documente em vez de perguntar. Limites reais de capacidade (credencial/dependência externa inexistente, ambiguidade sem opção segura) não são pontos de aprovação: escolha o caminho mais razoável, prossiga e relate a limitação só no resumo final.

**5. Commitar, abrir PR e sair.** Commite tudo dentro do worktree, publique a branch (`git push -u origin <branch>`) e abra um PR com `gh pr create`, com título e corpo que resumam a mudança e referenciem o plano. Depois use `ExitWorktree action: "keep"` para voltar ao diretório original sem apagar o worktree. Se não der para abrir PR (sem remoto, `gh` não autenticado, sem permissão de push), trate como limite de capacidade: mantenha as mudanças commitadas, saia com `ExitWorktree action: "keep"` e relate no resumo.

**6. Entregar de uma vez.** Ao concluir, entregue o resumo final numa única resposta: link do PR (ou caminho do worktree, se o PR não pôde ser aberto), caminho do plano, tarefas e arquivos concluídos, verificações rodadas e flows atualizados.

---

## Regras gerais

- **Decisão documentada, não perguntada** — toda escolha que normalmente iria ao usuário (design, ajustes no plano, início da execução) é feita pelo agente e registrada com uma frase de justificativa.
- **Interrupção a pedido** — se o usuário mandar parar a qualquer momento, pare na hora; se já estiver no worktree, saia com `ExitWorktree action: "keep"` preservando o que já foi commitado.
- **Idioma** — use o mesmo idioma da conversa.
