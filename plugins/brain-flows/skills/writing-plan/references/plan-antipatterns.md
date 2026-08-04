# Auditoria do plano

Lido no passo 4.5, com o plano já escrito e ainda não salvo. São duas partes: a **rubrica** decide se o plano passa, o **catálogo** nomeia o defeito quando ele não passa.

Auditar é corrigir os itens defeituosos, não reescrever o plano. Um achado isolado corrige um checkbox; só reestruture quando a mesma dimensão falhar em várias fases.

---

## Rubrica de aceite

Cinco dimensões, cada uma valendo 0, 1 ou 2. Atribua a nota olhando o plano escrito, não a intenção que você tinha ao escrevê-lo.

| # | Dimensão | 0 | 1 | 2 |
|---|----------|---|---|---|
| 1 | **Acionabilidade** | Há passos que não dizem onde mexer | A maioria nomeia arquivo e ação; alguns são genéricos | Todo checkbox nomeia arquivo/símbolo e ação concreta |
| 2 | **Verificabilidade** | Alguma fase não tem verificação, ou a verificação não prova nada | Verificações existem mas algumas são genéricas demais para a fase | Cada fase tem verificação que prova o resultado daquela fase, com comando real ou critério binário |
| 3 | **Fidelidade ao design** | O plano contraria a Decisão aprovada ou reintroduz alternativa descartada | Cobre a decisão mas adiciona escopo não discutido | Implementa exatamente a Decisão aprovada; o que foi além está registrado e justificado |
| 4 | **Proporcionalidade** | Há arquivo, camada ou fase sem razão concreta | Escopo defensável mas com folga | Toda peça do plano tem razão no problema, no padrão do projeto ou em pedido explícito |
| 5 | **Retomabilidade** | Passos só fazem sentido para quem acompanhou a conversa | Maior parte é auto-contida; algum passo depende de contexto externo | Alguém sem o histórico executa a partir do primeiro checkbox pendente |

**Corte:** qualquer dimensão com **0** bloqueia — corrija antes de salvar. Total abaixo de **8/10** exige uma passada de revisão. De 8 a 10 sem nenhum zero, salve.

Se a correção encolher o escopo abaixo do teto de fases, reavalie o formato no passo 2.7: um plano que virou multi-parte por inchaço deve voltar a ser arquivo único.

Registre a nota apenas na sua análise. O arquivo do plano não leva a rubrica.

---

## Catálogo de anti-padrões

Agrupados pela dimensão que derrubam.

### Acionabilidade

**P1 — Passo mudo.** O checkbox descreve uma intenção sem dizer onde ela acontece: "adicionar validação", "tratar erros", "ajustar o layout".
→ Nomeie arquivo e símbolo: "adicionar validação de e-mail em `src/features/login/EmailField.tsx`".

**P2 — Passo-container.** Uma fase inteira comprimida em um checkbox: "implementar o repositório", "construir a tela".
→ Quebre no trabalho real. Se o passo só é executável lendo o plano inteiro, ele não é um passo.

**P3 — Placeholder herdado.** Sobrou `<caminho>`, `<componente>`, `TBD` ou "ver depois" vindo do template.
→ Substitua por caminho real. Se o caminho depende de investigação, o passo é investigar — diga o que investigar e por quê.

### Verificabilidade

**P4 — Verificação decorativa.** "Verificar se funciona", "revisar o código", "confirmar que está correto".
→ Verificação é comando com saída ou critério binário observável. Se não há como provar a fase automaticamente, diga o que fica pendente de validação do usuário em vez de fingir uma checagem.

**P5 — Verificação emprestada.** Toda fase termina com o mesmo build genérico, que passaria mesmo se a fase não tivesse sido feita.
→ A verificação precisa falhar se a fase não for executada. Build limpo é piso, não evidência.

**P6 — Critério de sucesso não observável.** "Código limpo", "boa performance", "arquitetura consistente" na seção de Critérios de Sucesso.
→ Critério é resultado que alguém consegue conferir. Sem forma de conferir, não é critério.

**P7 — Teste de fachada.** Fase de teste que exercita o mock, o framework ou o próprio setup em vez do contrato da unidade. Ou fase de teste de componente em stack sem harness headless confirmado.
→ O teste tem que falhar quando a regra de negócio quebra. Para o segundo caso, ver `headless-testing.md`.

### Fidelidade ao design

**P8 — Drift de design.** O plano implementa algo que a Decisão aprovada não cobre, ou reintroduz uma alternativa listada como descartada.
→ Volte à decisão. Mudar de rumo no plano é decisão nova e pertence ao usuário, não ao planejamento.

**P9 — Reclassificação silenciosa.** O tipo de mudança do Handoff virou outro no plano sem registro do motivo.
→ Reclassificar é permitido quando o código contradiz o handoff, mas exige a frase de justificativa (passo 1.5).

### Proporcionalidade

**P10 — Camada especulativa.** Interface, abstração, config ou ponto de extensão criado "para quando precisarmos".
→ Corte. A razão tem que existir agora: regra de negócio, separação já usada no projeto, ou pedido explícito.

**P11 — Fase de enchimento.** "Documentação", "Refactor final", "Ajustes e polimento", "Testes gerais" sem passos concretos dentro.
→ Ou a fase tem trabalho nomeado, ou ela sai. Fase existe para ser concluída e verificada.

**P12 — Fatiamento por camada.** Em plano multi-parte, partes que separam por camada técnica ("parte 1: models, parte 2: repositórios") e por isso nenhuma entrega valor fechado.
→ Refatie por entrega, conforme `multi-part-plan.md`.

### Retomabilidade

**P13 — Contexto que ficou na conversa.** O passo depende de algo dito no chat e não escrito no plano: "usar a abordagem que discutimos", "conforme combinado".
→ Escreva a informação no plano. O executor pode ser outra sessão, outro agente, ou você depois de uma compactação.

---

## Falsos positivos

Não corrija o que não é defeito. Nenhum dos itens abaixo, sozinho, derruba nota:

- **Plano com muitos arquivos** quando a feature genuinamente toca muitos. Escopo real não é inchaço.
- **Testes antes da implementação** em mudança Logic. É a regra de TDD do passo 1.5, não inversão de ordem.
- **Passos parecidos entre fases** quando operam sobre arquivos diferentes. Repetição de forma não é redundância.
- **Ausência de fases de teste** em mudança UI-only cuja stack não tem harness headless. É a regra, não omissão.
- **Ausência de fase "Atualizar Flow"** quando a mudança é interna e não altera a estrutura documentada.
- **Validação funcional deixada para o usuário** no fim. É a política do projeto, não verificação faltando.
- **Plano longo** por ser multi-parte. Volume distribuído em partes é o formato correto, não excesso.

Na dúvida entre "isso é defeito" e "isso é o problema sendo complexo", pergunte se dá para remover a peça e ainda entregar a Decisão aprovada. Se não dá, ela fica.
