# Execução de plano multi-parte

Use esta referência quando o plano for uma pasta com `00-indice.md` e partes numeradas. Leia o índice para absorver objetivo, Design de Origem, ordem, dependências e a coluna `Delegável` da parte selecionada; depois leia por completo apenas a primeira parte pendente cujas dependências estejam concluídas. Não carregue partes futuras no contexto.

Antes de iniciar a parte selecionada, se ela estiver marcada `sim` na coluna `Delegável` e o ambiente oferecer subagente, delegue a parte inteira. O subagente recebe os caminhos do arquivo da parte e do índice, executa todos os passos, marca os checkboxes e roda as verificações; o retorno exigido são as evidências, não apenas a afirmação de conclusão. Se estiver marcada `não` ou não houver subagente, execute normalmente, passo a passo. Delegação é otimização, nunca requisito.

Confira as evidências retornadas contra as verificações da parte antes de marcar seu status no índice. Checkbox marcado sem evidência confirmada não vale. Só então marque a parte como concluída no `00-indice.md` e execute o checkpoint final: commit e resumo curto do que ficou pronto.

Não pergunte se deve continuar. Após o checkpoint, siga para a próxima parte pendente com dependências satisfeitas, repetindo leitura, execução e verificação até a última. Só pare por bloqueio real: verificação sem solução no escopo, dependência externa ausente ou correção que mudaria o Design de Origem.

Se o usuário pedir explicitamente apenas uma parte (por exemplo, "execute a parte 2"), conclua essa parte e pare.
