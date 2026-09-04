# Revisão de conclusão

Leia no passo 7, depois das tarefas e antes de declarar conclusão. Julga a execução, não o plano.

| # | Dimensão | 0 → 2 (uma frase) | Anti-padrões (ID + nome, 2–4 palavras) | Falso positivo (uma frase) |
|---|---|---|---|---|
| 1 | **Cobertura** | 0: pendência obrigatória sem bloqueio; 1: tudo marcado com interpretação frouxa; 2: todo item executado como escrito | E1 Checkbox otimista | Critério funcional desmarcado fica para o usuário |
| 2 | **Evidência** | 0: checkbox sem verificação; 1: prova indireta; 2: cada item tem saída que prova o resultado | E2 Afirmação no lugar da verificação; E3 Evidência obsoleta; E4 Verificação afrouxada | Verificação parcial declarada por limitação é válida |
| 3 | **Fidelidade** | 0: contraria decisão; 1: desvio não registrado; 2: corresponde ao Design de Origem e registra desvios | E5 Drift silencioso; E6 Escopo infiltrado; E7 Ampliação por conveniência | Menos arquivos por passo desnecessário, com registro, é válido |
| 4 | **Integridade** | 0: finais não rodaram ou houve mudança fora do escopo; 1: lateral não relatada; 2: finais limpas e escopo íntegro | E9 Plano reescrito durante a execução; E10 Conclusão com ressalva | Problema não relacionado pode ser relatado sem correção |
| 5 | **Rastreabilidade** | 0: mudança estrutural sem flow; 1: flow sem plano ou metadados renovados; 2: plano e flows fecham o elo | E8 Flow órfão | Ausência de flow é válida quando a estrutura não mudou |

**Corte:** qualquer 0 impede conclusão; total abaixo de **8/10** exige correção; 8–10 sem zero fecha o plano.

Se o zero depender de bloqueio externo, relate-o sem declarar conclusão. A nota fica na sua análise.
