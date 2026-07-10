# Guia: arquivos de instruções de projeto

> Use este guia para gerar instruções concisas e acionáveis em `CLAUDE.md` (Claude Code) ou `AGENTS.md` (Codex), sem misturar convenções exclusivas das plataformas.

## Sumário

1. Princípios fundamentais
2. Seleção do arquivo-alvo
3. Estrutura recomendada
4. Template enxuto
5. Hierarquia e disclosure progressivo
6. Anti-padrões
7. Checklist final

## 1. Princípios fundamentais

**Menos é mais.** Cada linha compete por atenção com a tarefa real. Prefira um arquivo raiz curto, normalmente entre 60 e 150 linhas e sempre abaixo de 200 quando possível.

**Teste de relevância.** Para cada linha, pergunte: “o agente erraria sem esta instrução?”. Remova orientações genéricas como “escreva código limpo”.

**Onboarding, não enciclopédia.** O arquivo deve responder:

- **O quê:** stack, estrutura e responsabilidades principais.
- **Por quê:** decisões e restrições que não são óbvias no código.
- **Como:** comandos reais para analisar, testar e gerar artefatos.

**Disclosure progressivo.** Mantenha no arquivo raiz somente regras universais. Regras específicas de módulos devem ficar próximas desses módulos ou em skills carregadas sob demanda.

## 2. Seleção do arquivo-alvo

- No Claude Code, use `CLAUDE.md`.
- No Codex, use `AGENTS.md`.
- Se a plataforma não estiver identificada, atualize somente o arquivo existente.
- Se ambos existirem, preserve ambos. Compartilhe apenas conteúdo neutro e mantenha comandos, sintaxe de skills e regras exclusivas em seu arquivo correspondente.
- Se nenhum existir e a plataforma for desconhecida, confirme o alvo antes de criar um arquivo.

Leia o arquivo existente antes de reescrevê-lo. Migre instruções específicas e ainda válidas; descarte duplicações e regras desatualizadas.

## 3. Estrutura recomendada

Adapte esta estrutura ao que foi confirmado no repositório:

```markdown
# [Nome do Projeto]

[Uma frase descrevendo o projeto, stack principal e plataforma alvo]

## Stack e arquitetura
## Estrutura do projeto
## Comandos essenciais
## Convenções
## Workflow e gotchas
## Não fazer
```

### 3.1 Cabeçalho

Comece com uma frase que dê contexto imediato:

```markdown
# CleanerForDevs

App macOS nativo em SwiftUI para limpeza de caches de desenvolvimento, distribuído pela Mac App Store.
```

### 3.2 Stack e arquitetura

Liste versões relevantes e decisões que não sejam inferíveis apenas pelos manifestos:

```markdown
## Stack

- Swift 5.9 / SwiftUI, mínimo macOS 13
- StoreKit 2 para compras

## Arquitetura

MVVM com lógica de limpeza isolada em `CleaningEngine`. A UI não acessa o filesystem diretamente.
```

### 3.3 Estrutura

Documente diretórios e seus propósitos, não um inventário de arquivos:

```markdown
## Estrutura

- `lib/features/` — features verticais
- `lib/core/` — DI, rede e persistência compartilhadas
- `test/` — espelha a estrutura de `lib/`
```

### 3.4 Comandos essenciais

Inclua apenas comandos encontrados no projeto ou confirmados pelo usuário:

```markdown
## Comandos

- `flutter test` — executa testes automatizados
- `flutter analyze` — executa análise estática
- `dart run build_runner build --delete-conflicting-outputs` — gera código
```

### 3.5 Convenções

Escreva regras específicas e verificáveis:

```markdown
## Convenções

- Estado: Riverpod 2.x; não introduza Provider legado
- Navegação: rotas tipadas em `lib/core/router/`
- Strings de UI: sempre via ARB
```

### 3.6 Workflow e gotchas

Registre decisões do time, armadilhas conhecidas e seus workarounds:

```markdown
## Gotchas

- O build de CI exige `pubspec.lock` versionado
- Código gerado deve ser atualizado antes da análise estática
```

### 3.7 Não fazer

Inclua proibições concretas que previnam erros recorrentes:

```markdown
## Não fazer

- Não rode upgrades de dependências sem solicitação explícita
- Não edite arquivos gerados manualmente
```

## 4. Template enxuto

```markdown
# [Projeto]

[Uma linha: finalidade, stack principal e plataforma alvo]

## Stack

- [Linguagem/framework + versão relevante]
- [Bibliotecas ou serviços críticos]

## Estrutura

- `path/` — propósito

## Comandos

- `comando` — descrição curta

## Convenções

- [Regra específica e acionável]

## Gotchas

- [Armadilha conhecida + workaround]

## Não fazer

- [Comportamento concreto a evitar]
```

Comece pelo template e adicione somente seções sustentadas por evidência no projeto.

## 5. Hierarquia e disclosure progressivo

O arquivo na raiz contém stack, comandos, convenções universais e riscos críticos. Instruções específicas de um módulo podem ficar em arquivos equivalentes dentro do subdiretório quando a plataforma oferecer herança de contexto.

Skills guardam workflows especializados ativados apenas quando relevantes. Não duplique o corpo de uma skill no arquivo raiz; indique quando invocá-la.

A sintaxe de invocação é específica da plataforma:

- Claude Code: documente o comando namespaced do plugin, por exemplo `/brain-flows:flow`.
- Codex: oriente o usuário a selecionar a skill com `$` ou mencioná-la explicitamente.
- Em texto compartilhado: use “invoque a skill `flow`”.

## 6. Anti-padrões

**Genérico demais.** Troque “escreva código testável” por comandos e padrões reais do projeto.

**Tudo no arquivo raiz.** Mova regras restritas a um módulo para contexto local ou skills.

**Documentar o óbvio.** Não copie integralmente dependências ou estrutura que o agente obtém dos manifestos.

**Instruções contraditórias.** Audite arquivos raiz, subdiretórios e skills para não impor padrões incompatíveis.

**Misturar plataformas.** Não coloque comandos `/plugin` do Claude em `AGENTS.md` nem instruções de seleção com `$` do Codex em `CLAUDE.md`.

**Esquecer de versionar.** O arquivo de instruções faz parte do projeto e deve ser revisável como o código.

## 7. Checklist final

- O arquivo-alvo corresponde à plataforma ativa?
- O arquivo tem menos de 200 linhas?
- O cabeçalho descreve o projeto em uma frase?
- Todos os caminhos e comandos foram encontrados no repositório?
- As convenções são específicas e acionáveis?
- Instruções existentes válidas foram preservadas?
- Regras de plataforma foram mantidas no arquivo correto?
- Não há contradições com arquivos em subdiretórios ou skills?
- A seção de flows orienta a invocar a skill `flow` sem assumir sintaxe universal?
