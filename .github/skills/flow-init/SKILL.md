---
name: flow-init
description: Analisa o projeto inteiro e inicializa a pasta ./docs/flow/ com um documento de estrutura geral do projeto e, opcionalmente, flows individuais de cada feature. Use quando o usuário pedir "inicializar flows", "criar flows do projeto", "mapear o projeto inteiro", "documentar a estrutura do projeto", "gerar todos os flows", "flow-init", "criar mapa do projeto", ou qualquer pedido de visão documental completa de um projeto antes de começar a trabalhar nele.
---

# Flow Init

## O que esta skill faz

Varre o repositório e inicializa a pasta `./docs/flow/` com:

1. **`docs/flow/project-structure.md`** — sempre criado. Estrutura geral: stack, arquitetura, camadas, features, serviços compartilhados e configuração.
2. **Flows individuais por feature** — opcionais, no formato da skill `flow`.

Se o usuário optar por não gerar os flows completos agora, cria **`docs/flow/flow-suggestions.md`** com a lista das features detectadas e o que cada flow cobriria.

Por fim, atualiza `AGENTS.md` como arquivo canônico de instruções compartilhadas e garante que o Claude Code o carregue por meio de um `CLAUDE.md` com o import `@AGENTS.md`.

---

## Fluxo de Execução

### Passo 1 — Detectar o stack e varrer o projeto

Não invente arquivos nem suponha estruturas — mapeie o código real.

**1a — Identificar o stack:** localize o manifesto de dependências (`pubspec.yaml`, `package.json`, `pyproject.toml`/`requirements.txt`, `go.mod`, `Cargo.toml`, `pom.xml`/`build.gradle`, `Gemfile`, `*.csproj`, `composer.json`…) e extraia nome do projeto, versão e dependências principais.

**1b — Mapear a estrutura**, com base no stack: ponto de entrada do app (`main.*`, `index.*`, `cmd/`…), rotas/navegação, injeção de dependência (arquivos com `injector`, `container`, `locator`, `di`, `module` no nome), inicialização/bootstrap, features/módulos (pastas de primeiro nível em `src/`, `lib/`, `app/`, `features/`…), código compartilhado (`common`, `shared`, `core`, `utils`, `services`), temas/estilos e testes.

O objetivo é uma lista real de features, serviços e camadas antes de escrever uma linha de documentação.

**1c — Registrar a origem da análise:** execute `git rev-parse --short HEAD` e `git status --porcelain` quando Git estiver disponível. Use o hash curto como `source_commit` e registre `source_state` como `clean` ou `dirty`. Fora de um repositório Git, use `not-available` nos dois campos.

---

### Passo 2 — Criar `docs/flow/project-structure.md`

Crie sempre, independente da resposta do usuário (`mkdir -p ./docs/flow`). Se o arquivo já existir, pergunte se deve atualizar ou regenerar antes de continuar.

#### Template obrigatório para `project-structure.md`

```markdown
---
generated_at: YYYY-MM-DD
source_commit: abc1234
source_state: clean
verified_at: YYYY-MM-DD
status: current
related_plans: []
---

# Estrutura do Projeto: [Nome do Projeto]

> **Resumo:** Uma frase descrevendo o que o projeto faz, qual stack utiliza e qual arquitetura adota.

## Stack e Tecnologias

| Elemento | Valor |
|----------|-------|
| Linguagem | [ex: Dart, TypeScript] |
| Framework | [ex: Flutter, Next.js] |
| Gerenciador de pacotes | [ex: pub, npm] |
| Principais dependências | [libs mais relevantes] |

## Arquitetura

[2–4 frases sobre a arquitetura adotada e como as camadas se comunicam. Use o vocabulário real do código — se usa "Cubit", escreva "Cubit".]

```
[Diagrama em texto, ex:]
Presentation → Domain ← Data
```

### Regras de dependência

- [Regra real encontrada, ex: "domain não importa data". Se não houver, omita esta subseção]

## Features

| Feature | Caminho principal | Descrição resumida |
|---------|------------------|-------------------|
| [feature] | `caminho/feature/` | O que essa feature faz |

## Camadas / Módulos Compartilhados

| Tipo | Caminho | Responsabilidade |
|------|---------|-----------------|
| [ex: Widgets, Serviços, Utils, Theme] | `caminho/` | ... |

## Configuração

| Componente | Arquivo | Responsabilidade |
|-----------|---------|-----------------|
| [ex: DI, Rotas, Bootstrap, Error handling] | `caminho/arquivo.ext` | ... |

_(Inclua apenas o que existe no projeto, com o vocabulário real.)_

## Dependências Externas Principais

| Pacote | Versão | Uso no projeto |
|--------|--------|---------------|
| [pacote] | x.y.z | Para que é usado |

## Observações

[Padrões não óbvios, TODOs, inconsistências, pontos de atenção. Se não houver, omita.]
```

---

### Passo 3 — Perguntar sobre flows individuais

Exiba a lista de features detectadas e pergunte:

```
Criei o documento de estrutura do projeto em `./docs/flow/project-structure.md`.

Features detectadas: [feature-1], [feature-2], ...

Deseja que eu crie os flows completos de todas as features agora?
- **Sim** — gero todos seguindo o formato da skill `flow`
- **Não** — crio um arquivo de sugestões com o que falta documentar
```

Aguarde a resposta antes de continuar.

---

### Passo 4a — Se SIM: criar flows individuais

Para cada feature, crie `./docs/flow/<feature>.md` seguindo **exatamente** o template e o processo da skill `flow`: varra o código real da feature e referencie apenas arquivos que existem. Ao final, informe quantos flows foram criados e liste os caminhos.

---

### Passo 4b — Se NÃO: criar `docs/flow/flow-suggestions.md`

```markdown
---
generated_at: YYYY-MM-DD
source_commit: abc1234
source_state: clean
verified_at: YYYY-MM-DD
status: current
related_plans: []
---

# Sugestões de Flows a Documentar

> Gerado em [data]. Invoque a skill `flow` para criar qualquer um destes flows.

## Flows Sugeridos

### [Nome da Feature]
**Arquivo a criar:** `docs/flow/<nome-kebab-case>.md`
**Resumo:** O que este flow documentaria — gatilho, camadas percorridas e resultado final.

---

[repita para cada feature detectada]

## Já documentados

- `docs/flow/project-structure.md` — Estrutura geral do projeto
```

Resumos concisos (1–2 frases) — é uma lista rápida de consulta, não documentação completa.

---

### Passo 5 — Atualizar as instruções compartilhadas

Após criar os arquivos de flow, use esta estrutura independentemente da plataforma ativa:

- **`AGENTS.md` é o arquivo canônico:** concentra as instruções completas e compartilhadas do projeto.
- **`CLAUDE.md` é a ponte para o Claude Code:** importa o arquivo canônico com `@AGENTS.md`.

Antes de substituir qualquer arquivo, leia `AGENTS.md` e `CLAUDE.md` quando existirem e preserve instruções válidas e específicas. Como o Claude Code também receberá o conteúdo de `AGENTS.md`, escreva nele apenas convenções compatíveis com ambas as plataformas. Prefira formulações neutras como “invoque a skill `flow`”; não use sintaxes exclusivas como `/brain-flows:flow` ou `$flow` nas instruções compartilhadas.

**5a — Ler o guia de boas práticas** em `references/guide-project-instructions.md`, resolvido a partir do diretório desta skill. Internalize: menos é mais, instruções específicas e acionáveis, sem redundância com o que o código já comunica.

**5b — Gerar `AGENTS.md` do zero** usando o template enxuto do guia (seção 4), preenchido com o que você descobriu no Passo 1. Aplique o checklist (seção 7) antes de salvar: cabeçalho de 1 frase, stack com decisões não inferíveis do código, estrutura de diretórios, comandos reais, convenções específicas, gotchas com workarounds e "não fazer" concretos.

Não invente seções — inclua apenas o que sabe de fato. Migre instruções anteriores válidas e específicas; descarte as genéricas.

Adicione ao final:

```markdown
## 📖 Documentação de Flows

Para qualquer feature ou fluxo, verifique a pasta `./docs/flow/`: leia os títulos dos arquivos `.md` disponíveis e, se algum for relevante para a tarefa atual, leia-o antes de implementar ou debugar. Invoque a skill `flow` para criar ou atualizar flows individuais.

## 🧪 Teste funcional

Após implementar, não execute o projeto para validar o resultado (rodar o app, emulador/simulador, dispositivo físico, servidor local, screenshots ou interação simulada). Teste funcional/visual é responsabilidade do usuário.

- Limite a verificação a análise estática, build/compile e testes automatizados
- Ao concluir, liste objetivamente o que o usuário deve testar manualmente
- Não pergunte se deve executar o projeto — só faça isso se o usuário pedir explicitamente
```

**5c — Criar ou validar a ponte `CLAUDE.md`:**

- Se `CLAUDE.md` não existir, crie-o com exatamente:

  ```markdown
  @AGENTS.md
  ```

- Se a primeira linha já for exatamente `@AGENTS.md`, mantenha o arquivo. Preserve abaixo do import qualquer instrução realmente exclusiva do Claude Code.
- Se `CLAUDE.md` for um symlink válido para `AGENTS.md`, considere a ponte funcional e preserve-o.
- Se `CLAUDE.md` for um arquivo regular sem o import, ou um symlink para outro destino, não o substitua silenciosamente. Separe as instruções compartilháveis das exclusivas do Claude, proponha migrar as compartilháveis para `AGENTS.md` e manter as exclusivas abaixo de `@AGENTS.md`, e peça confirmação antes de reescrever o arquivo.
- Nunca use apenas o texto `AGENTS.md`: sem o prefixo `@`, o Claude Code não o trata como import.
- Não duplique em `CLAUDE.md` as instruções já presentes em `AGENTS.md`.

---

### Passo 6 — Autorrevisar a documentação

Antes de finalizar, confronte cada documento criado ou atualizado com o repositório:

- Todos os caminhos citados existem?
- Features, módulos, dependências e comandos foram encontrados em arquivos reais?
- O vocabulário corresponde ao usado pelo projeto?
- Não existem placeholders ou afirmações sem evidência?
- `source_commit` e `source_state` correspondem ao estado analisado?
- `verified_at` registra a data desta revisão?
- Em arquivos atualizados, `generated_at` original e seções customizadas foram preservados?
- `related_plans` contém somente caminhos existentes e relacionados, ou `[]`?
- `AGENTS.md` concentra as instruções compartilhadas sem sintaxe exclusiva de plataforma?
- `CLAUDE.md` começa com `@AGENTS.md` ou é um symlink válido para `AGENTS.md`, sem duplicar as instruções canônicas?

Use `status: current` somente nos documentos que passaram por essa revisão. Se uma referência não puder ser confirmada, explique a limitação em **Observações** e marque o documento como `possibly-stale`. Use `draft` para documento incompleto e `archived` apenas por decisão explícita do usuário.

Os flows individuais criados no Passo 4a também devem passar pela autorrevisão definida na skill `flow`.

---

## Regras de Qualidade

**Apenas o que existe** — não documente arquivos, classes ou rotas que você não encontrou. Se algo parece faltar, registre em Observações.

**Vocabulário do projeto** — use os nomes que o código usa; não imponha terminologia externa.

**Conservador nas sugestões** — liste como feature apenas o que existe como pasta ou módulo distinto; não fragmente nem agrupe à força.

**Rastreabilidade honesta** — preserve a data original de criação em atualizações e sinalize alterações locais com `source_state: dirty`; não apresente um documento parcialmente verificado como atual.

**Não modifique código** — skill puramente documental; não altere nada além dos arquivos de flow, de `AGENTS.md` e da ponte `CLAUDE.md` descrita no Passo 5.

**Idioma** — o mesmo da conversa com o usuário.

---

## Ao finalizar

Informe: quais arquivos foram criados em `./docs/flow/`, o status de verificação de cada um, que `AGENTS.md` foi reescrito com base no guia, o estado da ponte `CLAUDE.md`, e como invocar a skill `flow` para criar ou atualizar flows individuais no futuro.
