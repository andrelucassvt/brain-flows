# Template do plano

Estrutura obrigatória do arquivo salvo em `./docs/plan/<nome>.md`. Escolha **um** dos dois templates de fases conforme o tipo de mudança e remova o outro antes de salvar.

```markdown
# [Título do Plano]

> **Objetivo:** Uma frase descrevendo o que será entregue ao final.
> **Design de origem:** brainstorming desta conversa | reconstruído a partir do pedido
> **Flows relacionados:** `docs/flow/<nome>.md`, ... (ou "nenhum")

## Contexto

[2–4 frases explicando o estado atual, o problema ou a motivação.]

## Design de Origem

<!--
  Copie aqui o Handoff do brainstorming (decisão + alternativas descartadas).
  Sem handoff, escreva a decisão de design em 1–2 frases.
  Esta seção é o que o executing-plan consulta para defender a intenção original
  ao lidar com drift — não a omita.
-->

- **Decisão aprovada:** [opção escolhida em uma frase]
- **Alternativas descartadas:** [opção + motivo, ou "nenhuma — caminho direto"]
- **Tipo de mudança:** UI-only | Logic

## Arquitetura / Escopo

[Tabela mapeando os arquivos/módulos afetados. Inclua apenas o que muda ou é criado.]

| Arquivo | Ação | Responsabilidade |
|---------|------|-----------------|
| `<caminho>` | criar | ... |

## Fases

[Template A ou B, conforme o tipo de mudança.]

## Critérios de Sucesso

- [ ] [resultado observável 1]
- [ ] [resultado observável 2]
- [ ] Build sem erros
- [ ] _(somente para mudanças Logic)_ Todos os testes unitários passando
- [ ] _(quando houver fase de teste de componente)_ Testes de componente/widget passando no harness
- [ ] _(manual — feito pelo usuário)_ Validação funcional no app

## Riscos e Mitigações

| Risco | Probabilidade | Mitigação |
|-------|--------------|-----------|
| ... | Baixa/Média/Alta | ... |

## Rollback

[Como desfazer as mudanças se algo der errado. Se não aplicável, escreva "N/A".]
```

---

## Template A — UI-only

```markdown
### Fase 1 — [Nome da Fase de UI]

- [ ] Passo 1: [ação concreta com arquivo e componente]
- [ ] Passo 2: ...
- [ ] Verificação: [checagem sem executar o app — ex: análise estática limpa, componente presente no arquivo]

_(repita para cada fase de UI)_

### Fase N — Teste de componente (após a UI existir)

- [ ] Criar `<caminho>/test/<componente>_test.<ext>` (widget/component test da stack)
- [ ] Testar que o componente renderiza os elementos-chave (texto, ícone, campo)
- [ ] Testar interação no harness: tap / entrada de texto → callback disparado ou estado visual muda
- [ ] Testar variação de estado visual relevante (vazio, erro, selecionado) quando aplicável
- [ ] Verificação: `<comando de teste da stack>` passa sem subir app/emulador/device
```

A fase de teste de componente entra **somente** quando a stack tem teste headless de UI confirmado pelas dependências (ver `headless-testing.md`) e sempre **depois** de o componente existir. Sem esse framework, o plano não tem fases de teste.

---

## Template B — Logic (TDD: testes primeiro)

```markdown
### Fase 1 — Testes (contrato antes da implementação)

> Os testes vão falhar inicialmente — isso é intencional.

- [ ] Criar `<caminho>/test/<arquivo>.test.<ext>`
- [ ] Testar caso de sucesso: [descrição]
- [ ] Testar caso de erro/falha: [descrição]
- [ ] Testar estado de loading (quando aplicável)
- [ ] Verificação: testes compilam e falham pelos motivos certos (não por erro de sintaxe)

### Fase 2 — Implementação (fazer os testes passarem)

- [ ] Implementar [ViewModel / Service / Repository / DataSource] em `<caminho>`
- [ ] Registrar no container de DI se necessário
- [ ] Verificação: testes passam sem erros

### Fase 3 — UI (se houver interface para a lógica implementada)

- [ ] Conectar View à camada de estado
- [ ] Verificação: análise/build limpos — o teste do fluxo de ponta a ponta é manual, do usuário

_(repita fases de implementação/UI conforme necessário)_
```
