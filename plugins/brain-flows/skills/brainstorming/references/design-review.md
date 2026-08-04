# Auditoria do design

Lido no passo 3.5, com o design escrito e ainda não apresentado ao usuário. A **rubrica** decide se o design pode ir para aprovação; o **catálogo** nomeia o defeito quando ele não pode.

Auditar aqui é barato: corrigir depois da aprovação custa uma segunda rodada de aprovação, e um defeito que passa daqui contamina o plano e a execução. A rubrica julga o design proposto, não o pedido do usuário.

---

## Rubrica de aceite

Cinco dimensões, cada uma valendo 0, 1 ou 2. Pontue o que está escrito, não a intenção que você tinha ao escrever.

| # | Dimensão | 0 | 1 | 2 |
|---|----------|---|---|---|
| 1 | **Fidelidade à intenção** | O design resolve um problema diferente do pedido | Resolve o pedido, mais algo que o usuário não pediu | Resolve o que foi pedido; qualquer ampliação está declarada como sugestão separada |
| 2 | **Alternativas honestas** | Há opção listada só para perder, ou o caminho direto foi declarado onde existe decisão real | Alternativas plausíveis, mas a recomendação não diz o que as separa | Cada opção é escolhível, e a recomendação aponta o critério do projeto que decidiu |
| 3 | **Proporcionalidade** | Há componente, camada ou etapa sem razão no problema | Design defensável, com folga | Toda peça vem de requisito, regra de negócio ou padrão já usado no projeto |
| 4 | **Handoff derivável** | Falta informação para preencher **Decisão aprovada**, **Tipo de mudança** ou **Arquivos-chave** | Todos os campos saem do design, mas algum fica genérico | Os seis campos do Handoff saem direto do design, com caminhos reais |
| 5 | **Precisão** | Há arquivo, símbolo ou flow citado que você não viu | Tudo verificado, mas alguma citação está imprecisa | Cada referência foi vista no código ou nos flows; nada deprecated sem substituto |

**Corte:** qualquer dimensão com **0** bloqueia — corrija antes de apresentar. Total abaixo de **8/10** exige uma passada de revisão. De 8 a 10 sem nenhum zero, apresente o design.

Se a dimensão 2 for reprovada porque as alternativas colapsam em uma só, o resultado correto é assumir o **caminho direto** da Fase 3, não fabricar uma terceira opção.

A nota fica na sua análise. O usuário recebe o design, não a rubrica.

---

## Catálogo de anti-padrões

Agrupados pela dimensão que derrubam.

### Fidelidade à intenção

**B1 — Pedido reinterpretado.** O design ataca o problema adjacente que pareceu mais interessante, ou generaliza um pedido específico em plataforma.
→ Desenhe o que foi pedido. O que você enxergou além vira observação nos Pontos de Atenção, para o usuário decidir.

**B2 — Suposição silenciosa.** Uma ambiguidade que mudaria o design foi resolvida por conta própria, sem a pergunta de clarificação e sem declarar a suposição.
→ Se muda o design, pergunte. Se dá para inferir do código com segurança, diga de onde veio a inferência.

### Alternativas honestas

**B3 — Alternativa de palha.** A Opção B existe para a A ganhar: desvantagens infladas, ou uma abordagem que ninguém escolheria.
→ Duas opções reais ou uma só. Alternativa de enfeite desperdiça a leitura do usuário e simula uma decisão que não houve.

**B4 — Alternativa clonada.** As opções diferem em detalhe de implementação, não em responsabilidades, dependências, experiência, manutenção, risco ou testabilidade.
→ Não é decisão real. Vá de caminho direto e explique o que o determina.

**B5 — Recomendação sem critério.** "Recomendo a Opção A por ser mais simples e escalável", sem nada do projeto ancorando a escolha.
→ Amarre a recomendação a este repositório: o padrão já usado, a regra de negócio, o flow existente, o custo concreto na stack.

### Proporcionalidade

**B6 — Design especulativo.** Abstração, ponto de extensão, camada ou config desenhada para um requisito que ninguém pediu.
→ Corte. Extensibilidade não pedida é escopo que o usuário vai pagar no plano e na execução.

**B7 — Briefing enciclopédico.** Flows reproduzidos quase palavra por palavra, ou seções preenchidas com texto de encher para não ficarem vazias.
→ O briefing sintetiza. Seção sem conteúdo real é omitida, não preenchida.

### Handoff derivável

**B8 — Handoff genérico.** "Arquivos-chave: os arquivos da feature de login", "Flows a revisitar: os relacionados" — campo preenchido sem informação utilizável.
→ Caminhos reais, um por item. O `writing-plan` recebe só este bloco; o que não estiver nele foi perdido.

**B9 — Classificação por aparência.** **Tipo de mudança** marcado UI-only porque o resultado é visível na tela, embora o design toque estado, serviço, repositório, datasource, HTTP ou banco.
→ Classifique pelas camadas que o design altera. Este campo decide a estratégia de TDD do plano inteiro, e o `writing-plan` não vai reclassificar.

### Precisão

**B10 — Caminho inventado.** Arquivo, classe ou rota citada por parecer plausível na convenção do projeto, sem ter sido vista no código ou em um flow.
→ Confirme antes de citar. Caminho errado no Handoff vira passo errado no plano.

**B11 — Deprecated silencioso.** O design usa API, widget, pacote ou padrão deprecated na versão atual da stack (ex: `withOpacity`, `WillPopScope` em Flutter) sem apontar o substituto.
→ Troque pelo substituto e registre a troca nos Pontos de Atenção.

---

## Falsos positivos

Nenhum destes, sozinho, derruba nota:

- **Uma única abordagem apresentada**, quando o padrão do projeto ou o próprio pedido a determina. É o caminho direto da Fase 3, não falta de alternativas.
- **Design curto** em mudança pequena. Proporcionalidade funcionando.
- **Handoff dispensado** em mudança pequena que vai direto à implementação.
- **"O que já existe" raso** quando não há flows no projeto. A skill manda seguir sem documentação, não bloquear.
- **Seções do briefing ausentes** por não terem conteúdo real.
- **"Skill expert: nenhuma encontrada"**. É resultado válido da busca, não busca malfeita.
- **Várias perguntas de clarificação em sequência**, uma por vez, quando o pedido é genuinamente ambíguo.
- **Fase 0 dispensando o fluxo** em mudança mecânica, com a frase de justificativa registrada.
