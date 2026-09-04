# Auditoria do design

Leia na Fase 3, antes de apresentar o design. A rubrica julga o que foi escrito; os IDs nomeiam defeitos e suas correções.

| # | Dimensão | 0 → 2 (uma frase) | Anti-padrões (ID + nome, 2–4 palavras) | Falso positivo (uma frase) |
|---|---|---|---|---|
| 1 | **Fidelidade à intenção** | 0: resolve outro problema; 1: inclui pedido e escopo não pedido; 2: resolve o pedido e declara ampliações | B1 Pedido reinterpretado; B2 Suposição silenciosa | Inferência segura do código não exige pergunta |
| 2 | **Alternativas honestas** | 0: opção de palha ou decisão real omitida; 1: opções plausíveis sem critério; 2: opções escolhíveis e critério do projeto | B3 Alternativa de palha; B4 Alternativa clonada; B5 Recomendação sem critério | Caminho direto é correto quando o padrão determina a solução |
| 3 | **Proporcionalidade** | 0: peça sem razão; 1: design defensável com folga; 2: toda peça vem do requisito, regra ou padrão | B6 Design especulativo | Design curto para mudança pequena é proporcional |
| 4 | **Densidade** | 0: estoura linhas ou enche seções; 1: cabe mas repete; 2: cada linha acrescenta informação | B7 Contexto enciclopédico; B12 Pedido devolvido; B13 Processo narrado; B14 Redundância entre seções | Seções sem conteúdo real podem ser omitidas |
| 5 | **Handoff derivável** | 0: faltam decisão, tipo ou arquivos; 1: campos genéricos; 2: seis campos saem com caminhos reais | B8 Handoff genérico; B9 Classificação por aparência | Handoff é dispensável quando a mudança pequena segue direto |
| 6 | **Precisão** | 0: citação não vista; 1: citação imprecisa; 2: referências conferidas e sem deprecated silencioso | B10 Caminho inventado; B11 Deprecated silencioso | Skill expert inexistente é resultado válido |

**Corte:** qualquer 0 bloqueia; total abaixo de **10/12** exige revisão; 10–12 sem zero pode ser apresentado.

Se alternativas colapsarem, assuma o caminho direto em vez de fabricar uma opção. Corrija densidade cortando seções, não comprimindo prosa. A nota fica na sua análise.
