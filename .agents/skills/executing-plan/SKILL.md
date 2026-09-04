---
name: executing-plan
description: Executa um plano de implementação Markdown já criado em ./docs/plan/, revisando-o antes de começar, retomando pelo primeiro checkbox pendente, implementando uma tarefa por vez, verificando cada etapa, marcando o progresso e atualizando flows afetados. Use quando o usuário pedir para executar, implementar, continuar ou retomar um plano existente, como "execute o plano", "implemente o plano", "continue o plano" ou "retome de onde parou".
license: MIT
metadata:
  version: "2.0.0"
---

# Executing Plan

Executa um plano existente sem misturar planejamento e implementação. O plano em `./docs/plan/` é a fonte de verdade do progresso: cada tarefa é verificada antes de ser marcada.

Não cria planos novos; para isso, encaminhe a `writing-plan`. A entrada ideal tem **Design de Origem**, que preserva a decisão aprovada durante o tratamento de drift. A saída é código verificado, plano atualizado e flows afetados relinkados ao plano.

### Referências

Resolvida a partir do diretório desta skill:

| Arquivo | Quando ler |
|---------|-----------|
| `references/multi-part-execution.md` | No passo 1, quando o plano for uma pasta com índice e partes |
| `references/completion-review.md` | No passo 7 — lida pelo revisor independente ou pela própria thread |

---

## Fluxo de execução

### 1. Localizar e ler o plano completo

Use o caminho informado. Se o usuário disser apenas "o plano", liste `./docs/plan/` e selecione o candidato compatível; pergunte somente se houver ambiguidade real.

**Plano multi-parte** (pasta com `00-indice.md` + partes numeradas): leia `references/multi-part-execution.md` antes de continuar.

**Plano de arquivo único:** leia-o inteiro antes de alterar código e identifique objetivo, critérios, **Design de Origem**, arquivos, ordem/dependências, verificações, riscos, rollback, flows relacionados e o primeiro checkbox pendente.

### 2. Revisar criticamente antes de executar

Confronte o plano com o repositório: procure arquivos movidos, contratos incompatíveis, passos vagos, dependências ausentes, ordem inexequível e verificações insuficientes.

Se estiver executável, informe em uma frase por onde começa. Ajuste apenas drift pequeno e inequívoco, registrando o motivo no plano. Se mudar escopo, arquitetura, comportamento, critérios ou contrariar a **Decisão aprovada**, pare e apresente o conflito ao usuário.

### 3. Retomar pelo progresso real

Comece no primeiro checkbox pendente com dependências satisfeitas. Não repita itens marcados, salvo evidência invalidada por mudança posterior; nesse caso, rerode apenas a verificação afetada e registre o motivo. Checkbox representa trabalho comprovado.

### 4. Executar uma tarefa por vez

Para cada checkbox, leia os arquivos relacionados, faça apenas a alteração necessária, rode a verificação definida, confira saída/status/falhas, marque `- [x]` só com evidência e avance.

Se falhar, mantenha desmarcado e corrija dentro do escopo; pare por falta de informação, autoridade, dependência externa ou mudança do design aprovado. Nunca troque verificação indisponível por afirmação; registre o que foi comprovado.

### 5. Manter o arquivo do plano atualizado

Além dos checkboxes, atualize o plano somente para registrar caminho alterado por drift, comando corrigido, bloqueio/desvio aprovado ou evidência concreta. Não o reescreva nem amplie o escopo.

### 6. Atualizar flows afetados

Depois da implementação e antes da revisão final, atualize um flow existente se mudarem arquivos participantes, responsabilidade, ordem, regra de negócio, erro/fallback, rota, DI, persistência ou integração externa.

Use a skill `flow` como fonte de verdade, preserve seções customizadas e renove seus metadados de verificação. Ao atualizar um flow, inclua o caminho deste plano no campo `related_plans` do frontmatter dele, fechando a rastreabilidade `plano → flow`. Mudanças internas que preservam a estrutura e o comportamento documentado não exigem atualização.

Se não existir flow relacionado, não crie um automaticamente: registre a ausência e sugira invocar a skill `flow` para documentá-lo na entrega.

### 7. Revisar a conclusão

Ao chegar ao fim, rode as verificações finais definidas no plano para detectar regressões. Em seguida leia `references/completion-review.md` e aplique a rubrica de conclusão às cinco dimensões (cobertura, evidência, fidelidade, integridade, rastreabilidade), corrigindo o que ela reprovar.

Um zero em qualquer dimensão impede declarar o plano concluído. Se ele não se resolver dentro do escopo — dependência externa, verificação indisponível, correção que mudaria o design aprovado — relate o bloqueio e o que ficou comprovado, em vez de fechar o plano.

**Revisão independente:** quando a mudança for `Logic` ou o plano tiver 3+ fases, e o ambiente oferecer subagente, despache um revisor em contexto limpo com o caminho do plano (incluindo Design de Origem e critérios), o `git diff` e os arquivos novos/não rastreados do escopo, e o caminho de `references/completion-review.md`. O revisor devolve nota por dimensão e achados com arquivo/linha; a thread corrige os achados e só então declara conclusão. Fora dessas condições, ou sem subagente, aplique a rubrica na própria thread. Achado sem evidência do revisor não reprova; "concluído" sem evidência do revisor não aprova.

Só declare o plano concluído quando todos os itens obrigatórios estiverem marcados e as verificações atuais sustentarem essa afirmação.

---

## Regras gerais

**Plano como fonte de verdade** — o estado dos checkboxes deve permitir retomar o trabalho após interrupção ou compactação de contexto.

**Escopo controlado** — problemas não relacionados encontrados durante a execução devem ser relatados, não incorporados silenciosamente.

**Verificação proporcional** — use exatamente as evidências previstas no plano e amplie apenas quando a alteração revelar risco de regressão diretamente relacionado. Testes no harness (unitários e de componente headless) são evidência válida; subir app, servidor, emulador, simulador, dispositivo, browser real, screenshot ou interação visual não é — a validação funcional é do usuário.

**Idioma do plano** — preserve o idioma em que o plano foi escrito ao atualizá-lo.

---

## Ao finalizar

Informe:

- Caminho do plano executado
- Tarefas e arquivos principais concluídos
- Verificações rodadas e seus resultados
- Flows atualizados, se houver
- Itens pendentes ou validações manuais do usuário, se houver

Não chame um plano de concluído se restar bloqueio ou critério obrigatório sem evidência.
