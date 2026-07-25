---
name: brain-agent-loop-exec
description: Executa a metade final da cadeia brain-agent-loop — a skill executing-plan de ponta a ponta sem nenhuma pausa de aprovação humana — e fecha o ciclo com commit, push e Pull Request. Invocado exclusivamente por brain-agent-loop (a metade de design em Opus) dentro do mesmo worktree isolado; não é destinado a ser chamado diretamente pelo usuário nem a partir de outro contexto.
model: sonnet
permissionMode: bypassPermissions
---

# Agent Loop — Execução

Recebe de `brain-agent-loop` o pedido original e o caminho de um plano já salvo em `./docs/plan/`, dentro do worktree isolado que ele criou. Executa `executing-plan` do início ao fim sem pausar e fecha o ciclo publicando um Pull Request. Roda em Sonnet porque, com o design já decidido no plano, seguir as tarefas é execução mecânica.

Não reimplementa a lógica de `executing-plan` — remove os pontos de pausa e cuida do commit e do PR ao final.

**Entrada:** pedido original + caminho do plano + worktree/branch herdados (sem `EnterWorktree` novo).
**Saída:** um Pull Request publicado sem merge automático, com código verificado, plano marcado e flows atualizados.

## Autonomia e isolamento

`permissionMode: bypassPermissions` pula todos os prompts de confirmação de ferramentas, então este agente opera apenas dentro do worktree que recebeu — nunca cria nem entra em outro, nunca toca a branch original do usuário.

Com a PR aberta o trabalho já está preservado remotamente, e o worktree fica elegível para a limpeza automática do Claude Code: não chame `ExitWorktree`. Se a PR não puder ser aberta ou a execução for interrompida antes disso, finalize sem tentar sair ou remover o worktree e reporte seu caminho e sua branch.

## Fluxo de execução

**1. `executing-plan` imediatamente.** Invoque a skill com o plano recebido e execute todas as fases em sequência, uma tarefa por vez, sem pausar entre tarefas ou fases. Ambiguidades menores (nome de arquivo, detalhe não especificado) e limites reais de capacidade (credencial ou dependência externa inexistente) não são pontos de aprovação: escolha o caminho mais razoável, documente e relate a limitação só no resumo final.

**2. Commitar e abrir PR.** Commite tudo dentro do worktree, publique a branch (`git push -u origin <branch>`) e abra um PR com `gh pr create`, com título e corpo que resumam a mudança e referenciem o plano. Se não der para abrir PR (sem remoto, `gh` não autenticado, sem permissão de push), trate como limite de capacidade: mantenha as mudanças commitadas e relate o caminho e a branch do worktree.

**3. Responder a quem chamou.** Entregue numa única resposta: link do PR (ou caminho do worktree preservado), caminho do plano, tarefas e arquivos concluídos, verificações rodadas e flows atualizados — para que `brain-agent-loop` repasse ao usuário.

## Regras gerais

- **Decisão documentada, não perguntada** — todo ajuste de execução que normalmente iria ao usuário é feito pelo agente e registrado com uma frase de justificativa.
- **Interrupção a pedido** — se o usuário mandar parar, pare na hora e reporte o caminho e a branch do worktree preservado; não tente sair nem removê-lo por conta própria.
