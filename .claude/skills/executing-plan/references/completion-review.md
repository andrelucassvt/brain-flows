# Revisão de conclusão

Lido no passo 7, com todas as tarefas executadas e antes de declarar o plano concluído. A rubrica decide se a execução pode ser chamada de pronta; o catálogo nomeia o defeito quando ela não pode.

Esta revisão julga a **execução**, não o plano. Defeito no plano em si já deveria ter parado a execução no passo 2.

---

## Rubrica de conclusão

Cinco dimensões, cada uma valendo 0, 1 ou 2.

| # | Dimensão | 0 | 1 | 2 |
|---|----------|---|---|---|
| 1 | **Cobertura** | Há checkbox obrigatório pendente sem bloqueio registrado | Tudo marcado, mas algum item foi concluído por interpretação frouxa do passo | Todo item obrigatório foi executado como escrito; pendências têm bloqueio registrado |
| 2 | **Evidência** | Algum checkbox foi marcado sem a verificação ter rodado | Verificações rodaram, mas alguma evidência é indireta demais para o critério | Cada item marcado tem saída de verificação que prova aquele resultado |
| 3 | **Fidelidade** | O implementado contraria a Decisão aprovada do Design de Origem | Segue a decisão, com desvio pequeno não registrado | Corresponde ao Design de Origem; todo desvio está registrado com motivo |
| 4 | **Integridade** | Verificações finais não rodaram, ou entrou mudança fora do escopo | Verificações rodaram, mas alguma mudança lateral não foi relatada | Verificações finais limpas e nenhuma alteração além do escopo do plano |
| 5 | **Rastreabilidade** | Mudança estrutural feita sem atualizar o flow correspondente | Flow atualizado, mas sem o `related_plans` ou sem renovar metadados | Plano e flows afetados atualizados, com `related_plans` fechando o elo |

**Corte:** qualquer dimensão com **0** impede declarar o plano concluído. Total abaixo de **8/10** exige uma passada de correção antes do relatório final. De 8 a 10 sem nenhum zero, feche o plano.

Se um zero não puder ser resolvido dentro do escopo (dependência externa, verificação indisponível, correção que mudaria o design), o plano não é declarado concluído: relate o bloqueio e o que ficou comprovado.

A nota fica na sua análise. O arquivo do plano não leva a rubrica.

---

## Catálogo de anti-padrões

### Cobertura e evidência

**E1 — Checkbox otimista.** Marcado porque o código foi escrito, sem a verificação do passo ter rodado.
→ O checkbox representa trabalho comprovado. Rode a verificação ou deixe desmarcado.

**E2 — Afirmação no lugar da verificação.** "Deve funcionar", "a lógica está correta", "equivalente ao que já existia" substituindo a evidência.
→ Registre o que não pôde ser comprovado, em vez de comprovar por raciocínio.

**E3 — Evidência obsoleta.** A verificação passou, e uma mudança posterior tocou o mesmo código sem que ela fosse rodada de novo.
→ Rerode a verificação afetada. Evidência tem data.

**E4 — Verificação afrouxada.** O comando do plano falhou e foi trocado por um mais permissivo até passar.
→ Corrigir comando por drift é legítimo e vai registrado; trocar para conseguir passar não é.

### Fidelidade e escopo

**E5 — Drift silencioso.** Um passo foi implementado de forma diferente da escrita porque era mais fácil, sem registro.
→ Registre o desvio e o motivo. Se ele contraria a Decisão aprovada, era para ter parado.

**E6 — Escopo infiltrado.** Correção, refactor ou melhoria não relacionada entrou junto porque estava ali.
→ Relate o problema encontrado; não incorpore. Mudança fora do plano polui a revisão e o rollback.

**E7 — Ampliação por conveniência.** O plano previa um arquivo e a execução criou três, sem que o plano previsse.
→ Ou o plano estava errado e o ajuste vai registrado, ou é escopo novo e pertence ao usuário.

### Rastreabilidade

**E8 — Flow órfão.** A mudança alterou arquivos participantes, ordem de execução, responsabilidade de camada ou regra de negócio, e o flow correspondente ficou como estava.
→ Atualize o flow e preencha `related_plans` com o caminho deste plano.

**E9 — Plano reescrito durante a execução.** Passos reformulados, fases removidas ou critérios suavizados ao longo do caminho.
→ O plano registra a execução real, não vira retrato do que deu certo. Só as atualizações do passo 5 são permitidas.

**E10 — Conclusão com ressalva.** Declarar o plano concluído seguido de "faltando apenas X".
→ Se falta X, o plano não está concluído. Relate o estado real.

---

## Falsos positivos

Nenhum destes derruba nota:

- **Critério de validação funcional desmarcado.** A validação no app é do usuário; deixá-lo desmarcado é a regra, não pendência da execução.
- **Passo ajustado por drift confirmado** do repositório, com o motivo registrado no plano.
- **Menos arquivos que o previsto**, quando um passo se mostrou desnecessário e isso foi registrado.
- **Verificação parcial por limitação do ambiente**, quando o que não pôde ser comprovado está declarado.
- **Ausência de atualização de flow** quando a mudança foi interna e preservou a estrutura documentada.
- **Problema não relacionado relatado e não corrigido.** É escopo controlado funcionando.
- **Plano multi-parte com partes futuras pendentes**, quando o usuário recortou explicitamente o pedido a uma parte.
