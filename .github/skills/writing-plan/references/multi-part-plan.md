# Plano multi-parte

Estrutura obrigatória quando a estimativa do passo 2.7 passa do teto de ~6 fases. O plano completo — com todas as partes detalhadas — é escrito de uma vez; a divisão em arquivos existe para a execução acontecer em sessões curtas, com checkpoint natural (commit + validação) entre partes, e para o `executing-plan` retomar parte a parte sem carregar um monólito.

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

| # | Arquivo | Entrega | Depende de | Status |
|---|---------|---------|-----------|--------|
| 1 | `01-<parte-um>.md` | [o que funciona ao concluir] | — | pendente |
| 2 | `02-<parte-dois>.md` | [o que funciona ao concluir] | 1 | pendente |

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
- [ ] Checkpoint: commit das mudanças da parte + informar o usuário que a parte N está concluída e a parte N+1 está pronta para execução
```

O checkpoint é o que transforma a divisão em arquivos em pausa real: sem ele, a execução vira a mesma maratona de antes, só que em vários arquivos.

## O que não muda

- Templates A/B de fases, regras de qualidade e a regra "verificação nunca executa o app" valem para cada parte, sem exceção.
- A seção **Após a Implementação** (pergunta sobre criar flow) fica na **última parte**, não no índice nem em todas as partes.
- Fase final **"Atualizar Flow"**, quando aplicável (passo 2 do `SKILL.md`), também fica na última parte.
