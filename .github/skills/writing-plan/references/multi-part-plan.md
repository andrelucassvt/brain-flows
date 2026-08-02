# Plano multi-parte

Estrutura obrigatória quando a estimativa do passo 2.7 passa do teto de ~6 fases. O plano completo — com todas as partes detalhadas — é escrito de uma vez; a divisão em arquivos existe para o `executing-plan` avançar parte a parte sem carregar um monólito no contexto, com checkpoint natural (commit + repositório íntegro) ao fim de cada entrega. O checkpoint não interrompe a execução: quem executa o plano executa todas as partes até a última.

## Layout

```
docs/plan/<nome-do-plano>/
├── 00-indice.md
├── 01-<parte-um>.md
├── 02-<parte-dois>.md
└── ...
```

## Como fatiar

- Cada parte é uma **entrega fechada**: ao final dela, algo observável funciona e o repositório está em estado íntegro (build/testes passando). Fatie por valor entregue (setup → serviço → integração → UI), não por camada técnica solta.
- Respeite dependências: a numeração é a ordem de execução; uma parte só depende de partes anteriores.
- Cada parte respeita o teto de ~6 fases. Se uma parte estourar o teto, o fatiamento está errado — refatere.

### Avaliar delegação para subagentes

Ao fatiar, avalie cada parte contra os 5 critérios abaixo. Só marque delegável (`sim`) quando **todos** forem verdadeiros:

1. **Contexto auto-contido** — a parte se executa lendo só o próprio arquivo + código referenciado, sem depender de discussão fora dele.
2. **Arquivos disjuntos** das demais partes ainda pendentes — nenhuma sobreposição de arquivo editado.
3. **Verificação 100% automatizada** com critério binário (passa/falha), sem julgamento humano na checagem.
4. **Sem decisão de design em aberto** — a Decisão aprovada no Design de Origem já cobre a parte inteira; nada fica para decidir durante a execução.
5. **Blast radius contido** — a parte não abre um contrato (interface, schema, rota) que outra parte pendente vai consumir.

Duas regras derivadas:

- Parte **UI-only sem teste de componente headless** é sempre `não` — a evidência de conclusão é a validação funcional do usuário, que não pode ser delegada.
- A delegação é **por parte inteira**: o subagente executa do primeiro ao último checkbox da parte, marca os checkboxes no próprio arquivo e roda as verificações definidas — nunca uma fração da parte.

## 00-indice.md

```markdown
# [Título do Plano] — Índice

> **Objetivo:** Uma frase descrevendo o que será entregue ao final de todas as partes.
> **Design de origem:** brainstorming desta conversa | reconstruído a partir do pedido
> **Flows relacionados:** `docs/flow/<nome>.md`, ... (ou "nenhum")

## Contexto

[2–4 frases explicando o estado atual, o problema ou a motivação.]

## Design de Origem

- **Decisão aprovada:** [opção escolhida em uma frase]
- **Alternativas descartadas:** [opção + motivo, ou "nenhuma — caminho direto"]
- **Tipo de mudança:** UI-only | Logic

## Partes

| # | Arquivo | Entrega | Delegável | Depende de | Status |
|---|---------|---------|-----------|-----------|--------|
| 1 | `01-<parte-um>.md` | [o que funciona ao concluir] | sim/não — [motivo curto] | — | pendente |
| 2 | `02-<parte-dois>.md` | [o que funciona ao concluir] | sim/não — [motivo curto] | 1 | pendente |

O motivo curto é obrigatório em ambos os casos — força a avaliação explícita dos critérios acima em vez de um `sim`/`não` mecânico.

## Riscos e Mitigações (globais)

[Riscos que atravessam partes. Riscos locais ficam na parte.]

## Rollback (global)

[Como desfazer o conjunto. Se não aplicável, escreva "N/A".]
```

O **Design de Origem vive só no índice** — as partes referenciam este arquivo em vez de repetir a decisão, para não divergir.

## Partes (`NN-<nome>.md`)

Cada parte usa a **estrutura obrigatória de `plan-template.md`** (Contexto, Arquitetura/Escopo, Fases no template A ou B, Critérios de Sucesso, Riscos, Rollback), com dois ajustes:

1. **Cabeçalho enxuto**, apontando para o índice em vez de repetir o design:

```markdown
# [Título do Plano] — Parte N: [Nome da Parte]

> **Objetivo da parte:** [o que funciona ao concluir esta parte]
> **Plano:** `00-indice.md` (Design de Origem, ordem e dependências)
> **Depende de:** parte N-1 concluída (ou "nenhuma")
```

2. **Encerramento com checkpoint**, como último passo da última fase:

```markdown
- [ ] Checkpoint: commit das mudanças da parte + resumo curto do que ficou pronto, seguindo direto para a parte N+1
```

O checkpoint é o que mantém o repositório íntegro entre partes — um commit por entrega fechada e um ponto de retomada claro caso a sessão caia. Ele **não** é uma pausa para aprovação: a execução continua na parte seguinte até a última, e só para por bloqueio real ou recorte explícito do usuário.

## O que não muda

- Templates A/B de fases, regras de qualidade e a regra "verificação nunca executa o app" valem para cada parte, sem exceção.
- A seção **Após a Implementação** (pergunta sobre criar flow) fica na **última parte**, não no índice nem em todas as partes.
- Fase final **"Atualizar Flow"**, quando aplicável (passo 2 do `SKILL.md`), também fica na última parte.
