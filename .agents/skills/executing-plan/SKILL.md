---
name: executing-plan
description: Executa um plano de implementação Markdown já criado em ./docs/plan/, revisando-o antes de começar, retomando pelo primeiro checkbox pendente, implementando uma tarefa por vez, verificando cada etapa, marcando o progresso e atualizando flows afetados. Use quando o usuário pedir para executar, implementar, continuar ou retomar um plano existente, como "execute o plano", "implemente o plano", "continue o plano" ou "retome de onde parou".
---

# Executing Plan

## O que esta skill faz

Executa um plano existente sem misturar planejamento com implementação. O arquivo em `./docs/plan/` permanece como fonte de verdade do progresso: cada tarefa é revisada, executada, verificada e marcada assim que for realmente concluída.

Esta skill não cria um plano novo. Se ainda não houver plano e a mudança exigir várias etapas, encaminhe para `writing-plan`.

### Entrada esperada

Um arquivo de plano em `./docs/plan/`, idealmente com a seção **Design de Origem** (produzida pelo `writing-plan`). Essa seção é a memória da decisão aprovada — é o que permite executar sem depender do histórico de conversa e defender a intenção original diante de drift.

### Saída (Handoff)

Código implementado e verificado, plano com progresso marcado, e os flows estruturalmente afetados atualizados e relinkados ao plano. Fecha a cadeia `brainstorm → plan → execução → flow`.

---

## Fluxo de execução

### 1. Localizar e ler o plano completo

Use o caminho informado pelo usuário. Se ele disser apenas "o plano", liste `./docs/plan/*.md`, selecione o único candidato compatível com a conversa ou faça uma pergunta curta quando houver ambiguidade real.

Leia o arquivo inteiro antes de alterar código. Identifique:

- Objetivo e critérios de sucesso
- **Design de Origem** — a decisão aprovada e as alternativas descartadas; é o limite que separa uma correção de drift legítima de uma mudança de rumo que exige o usuário
- Arquivos que serão criados ou modificados
- Ordem e dependências entre tarefas/fases
- Comandos e evidências de verificação
- Riscos, rollback e flows afetados (cabeçalho **Flows relacionados**)
- Checkboxes já concluídos e primeiro checkbox pendente

### 2. Revisar criticamente antes de executar

Confronte o plano com o estado atual do repositório. Procure arquivos movidos, contratos incompatíveis, passos vagos, dependências ausentes, ordem inexequível ou verificações que não provam o resultado esperado.

- Se o plano estiver executável, informe em uma frase por onde começará e prossiga.
- Se houver ajuste pequeno e inequívoco causado por drift do código, atualize o passo no plano e registre o motivo.
- Se a correção mudar escopo, arquitetura, comportamento ou critérios de sucesso — ou contrariar a **Decisão aprovada** no Design de Origem — pare e apresente o conflito ao usuário; não improvise uma solução diferente. O Design de Origem é o parâmetro: uma correção que reintroduz uma alternativa explicitamente descartada não é drift mecânico, é uma nova decisão.

### 3. Retomar pelo progresso real

Comece no primeiro checkbox pendente cujas dependências estejam satisfeitas. Não repita tarefas marcadas, exceto quando uma mudança posterior invalidar sua evidência; nesse caso, execute novamente apenas a verificação necessária e registre o motivo.

O checkbox representa trabalho comprovadamente concluído, não apenas código escrito.

### 4. Executar uma tarefa por vez

Para cada tarefa ou checkbox:

1. Leia o passo e os arquivos relacionados antes de editar.
2. Faça somente as alterações necessárias para aquele resultado.
3. Rode a verificação definida no plano.
4. Confira output, código de saída e falhas relevantes.
5. Marque `- [x]` imediatamente quando a evidência confirmar a conclusão.
6. Avance para o próximo item pendente.

Se uma verificação falhar, mantenha o checkbox desmarcado, investigue a causa dentro do escopo do passo e tente corrigir. Pare quando faltar informação, autoridade, dependência externa ou quando a correção exigir mudar o design aprovado.

Não substitua uma verificação indisponível por uma afirmação de que "deve funcionar". Registre o que foi e o que não pôde ser comprovado.

### 5. Manter o arquivo do plano atualizado

Além dos checkboxes, atualize o plano somente quando necessário para refletir a execução real:

- Caminho ou nome que mudou por drift confirmado do repositório
- Comando de verificação corrigido
- Nota curta sobre bloqueio ou desvio aprovado
- Critério que recebeu evidência concreta

Não reescreva o plano durante a execução nem amplie o escopo sem autorização.

### 6. Atualizar flows afetados

Depois de concluir as tarefas de implementação e antes da revisão final, atualize um flow existente quando a mudança tiver alterado:

- Arquivos participantes do processo
- Responsabilidade de uma camada ou componente
- Ordem de execução
- Regra de negócio, caminho de erro ou fallback
- Rota, injeção de dependência, persistência ou integração externa

Use a skill `flow` como fonte de verdade, preserve seções customizadas e renove seus metadados de verificação. Ao atualizar um flow, inclua o caminho deste plano no campo `related_plans` do frontmatter dele, fechando a rastreabilidade `plano → flow`. Mudanças internas que preservam a estrutura e o comportamento documentado não exigem atualização.

Se não existir flow relacionado, não crie um automaticamente: registre a ausência e sugira invocar a skill `flow` para documentá-lo na entrega.

### 7. Revisar a conclusão

Ao chegar ao fim:

1. Releia os critérios de sucesso e confronte cada um com evidência atual.
2. Rode as verificações finais definidas no plano para detectar regressões.
3. Confirme que não restam checkboxes de implementação ou verificação pendentes.
4. Confirme que os flows estruturalmente afetados foram atualizados.
5. Mantenha desmarcado qualquer critério que não tenha sido comprovado.

Só declare o plano concluído quando todos os itens obrigatórios estiverem marcados e as verificações atuais sustentarem essa afirmação.

---

## Regras gerais

**Plano como fonte de verdade** — o estado dos checkboxes deve permitir retomar o trabalho após interrupção ou compactação de contexto.

**Escopo controlado** — problemas não relacionados encontrados durante a execução devem ser relatados, não incorporados silenciosamente.

**Verificação proporcional** — use exatamente as evidências previstas no plano e amplie apenas quando a alteração revelar risco de regressão diretamente relacionado.

**Respeito ao ambiente** — não execute app, servidor, emulador, simulador, dispositivo, screenshot ou interação visual quando o plano reserva a validação funcional ao usuário.

**Idioma** — use o mesmo idioma da conversa e preserve o idioma do plano.

---

## Ao finalizar

Informe:

- Caminho do plano executado
- Tarefas e arquivos principais concluídos
- Verificações rodadas e seus resultados
- Flows atualizados, se houver
- Itens pendentes ou validações manuais do usuário, se houver

Não chame um plano de concluído se restar bloqueio ou critério obrigatório sem evidência.
