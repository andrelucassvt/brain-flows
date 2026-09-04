# Auditoria do plano

Leia no passo 4.5, com o plano escrito e ainda não salvo. Julgue o plano escrito, não sua intenção.

| # | Dimensão | 0 → 2 (uma frase) | Anti-padrões (ID + nome, 2–4 palavras) | Falso positivo (uma frase) |
|---|---|---|---|---|
| 1 | **Acionabilidade** | 0: não diz onde; 1: maioria nomeia arquivo, alguns são genéricos; 2: todo checkbox nomeia arquivo/símbolo e ação | P1 Passo mudo; P2 Passo-container; P3 Placeholder herdado | Muitos arquivos são válidos quando a feature realmente os toca |
| 2 | **Verificabilidade** | 0: fase sem prova; 1: prova genérica; 2: cada fase tem comando real ou critério binário próprio | P4 Verificação decorativa; P5 Verificação emprestada; P6 Sucesso não observável; P7 Teste de fachada | Testes vêm antes da lógica; UI sem harness não ganha fase de teste |
| 3 | **Fidelidade ao design** | 0: contraria decisão; 1: adiciona escopo; 2: implementa decisão e registra qualquer além | P8 Drift de design; P9 Reclassificação silenciosa | Reclassificar por contradição do código é válido se justificado |
| 4 | **Proporcionalidade** | 0: peça sem razão; 1: escopo defensável com folga; 2: toda peça tem razão concreta | P10 Camada especulativa; P11 Fase de enchimento; P12 Fatiamento por camada | Plano longo multi-parte é correto quando o escopo exige |
| 5 | **Retomabilidade** | 0: depende da conversa; 1: parte depende de contexto externo; 2: outra sessão executa do primeiro pendente | P13 Contexto que ficou na conversa | Validação funcional fica para o usuário |

**Corte:** qualquer 0 bloqueia; total abaixo de **8/10** exige revisão; 8–10 sem zero pode ser salvo.

Se a correção encolher o escopo abaixo do teto de fases, reavalie o formato no passo 2.7. A nota fica na sua análise.
