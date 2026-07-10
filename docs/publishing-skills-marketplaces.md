# Publicar o Brain Flows no Claude Code e no Codex

> Guia verificado em 10 de julho de 2026.

Este documento descreve como empacotar e distribuir as cinco skills sincronizadas por `sync-brain.sh`:

- `brainstorming`
- `flow`
- `flow-init`
- `writing-plan`
- `executing-plan`

O arquivo `docs/flow/sync-brain.md` documenta a sincronização, mas não é o conteúdo que deve ser publicado. A fonte editável continua sendo `.claude/skills/<skill>/`. Os diretórios `.github/skills/` e `.agents/skills/` são espelhos e não devem ser editados diretamente.

## Estratégia recomendada

Publique as cinco skills juntas em um plugin chamado `brain-flows`. Elas formam um único processo:

1. `brainstorming` explora a mudança e define o design.
2. `writing-plan` transforma o design em um plano rastreável.
3. `executing-plan` implementa e acompanha o plano.
4. `flow` documenta uma feature de ponta a ponta.
5. `flow-init` inicializa a documentação estrutural e o inventário de flows.

Use um repositório público de distribuição separado, por exemplo `ANL-Software/brain-flows-marketplace`. Isso evita expor partes desnecessárias do hub privado e permite controlar versões, licença, documentação e releases do plugin.

O mesmo diretório `skills/` pode ser consumido pelo Claude Code e pelo Codex. Cada plataforma terá apenas seu próprio manifest e arquivo de marketplace.

## 1. Preparar as skills para as duas plataformas

Antes de empacotar, ajuste os arquivos originais em `.claude/skills/` e execute o sync para atualizar os espelhos.

### 1.1 Remover caminhos exclusivos do Claude

`brainstorming/SKILL.md` procura skills expert somente em `.claude/skills/*-expert`. Torne essa busca independente de plataforma ou considere, na ordem disponível:

- `.claude/skills/*-expert`
- `.agents/skills/*-expert`
- o catálogo de skills exposto pelo próprio agente

### 1.2 Tratar o arquivo de instruções da plataforma

`flow-init/SKILL.md` atualmente atualiza `CLAUDE.md`. Defina o comportamento por plataforma:

- Claude Code: atualizar `CLAUDE.md`.
- Codex: atualizar `AGENTS.md`.
- Plataforma não identificada: atualizar apenas o arquivo que já existir; se ambos existirem, preservar os dois e aplicar somente instruções compatíveis.

O guia `flow-init/references/guide-claude-md.md` também deve ganhar orientação equivalente para `AGENTS.md` ou ser substituído por uma referência neutra sobre arquivos de instruções do projeto.

### 1.3 Usar nomes neutros nas instruções internas

Evite tratar `/flow`, `/writing-plan` e comandos semelhantes como sintaxe universal. Prefira frases como:

> Invoque a skill `flow` para criar ou atualizar o documento.

Documente a sintaxe específica no `README.md`:

- Claude Code: `/brain-flows:flow`.
- Codex CLI/IDE: digitar `$` e selecionar `flow`, ou mencionar explicitamente a skill no prompt.

## 2. Criar o repositório de distribuição

Use esta estrutura:

```text
brain-flows-marketplace/
├── .claude-plugin/
│   └── marketplace.json
├── .agents/
│   └── plugins/
│       └── marketplace.json
├── plugins/
│   └── brain-flows/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── .codex-plugin/
│       │   └── plugin.json
│       └── skills/
│           ├── brainstorming/
│           │   ├── SKILL.md
│           │   └── evals/
│           ├── flow/
│           │   ├── SKILL.md
│           │   └── evals/
│           ├── flow-init/
│           │   ├── SKILL.md
│           │   ├── evals/
│           │   └── references/
│           ├── writing-plan/
│           │   ├── SKILL.md
│           │   └── evals/
│           └── executing-plan/
│               ├── SKILL.md
│               └── evals/
├── README.md
└── LICENSE
```

Não mantenha essas cópias manualmente. Crie um script de empacotamento ou uma automação que execute `rsync -a --delete` da fonte `.claude/skills/<skill>/` para `plugins/brain-flows/skills/<skill>/`.

O script deve copiar somente as cinco skills de `BRAIN_SKILLS`. Assim, `.claude/skills/` permanece como fonte de verdade e o repositório público vira apenas o artefato distribuível.

## 3. Criar o plugin do Claude Code

Crie `plugins/brain-flows/.claude-plugin/plugin.json`:

```json
{
  "name": "brain-flows",
  "description": "Brainstorming, documentação de flows, planejamento e execução estruturada de mudanças.",
  "version": "1.0.0",
  "author": {
    "name": "ANL Software"
  },
  "homepage": "https://github.com/ANL-Software/brain-flows-marketplace",
  "repository": "https://github.com/ANL-Software/brain-flows-marketplace",
  "license": "MIT"
}
```

Quando `version` estiver presente, aumente seu valor a cada release. Caso contrário, o Claude Code pode usar o commit Git como versão.

## 4. Criar o marketplace do Claude Code

Crie `.claude-plugin/marketplace.json` na raiz do repositório:

```json
{
  "name": "anl-skills",
  "owner": {
    "name": "ANL Software"
  },
  "description": "Skills da ANL Software para desenvolvimento orientado por documentação.",
  "plugins": [
    {
      "name": "brain-flows",
      "source": "./plugins/brain-flows",
      "description": "Workflow de brainstorming, flows, planejamento e execução.",
      "category": "Development"
    }
  ]
}
```

O nome `anl-skills` é público e aparece no comando de instalação. Não use nomes reservados ou que façam o marketplace parecer oficial da Anthropic.

## 5. Validar e instalar no Claude Code

Na raiz do repositório de distribuição, valide o marketplace e o plugin:

```bash
claude plugin validate .
claude plugin validate ./plugins/brain-flows
```

Para testar uma cópia local:

```text
/plugin marketplace add ./caminho/para/brain-flows-marketplace
/plugin install brain-flows@anl-skills
/reload-plugins
```

Teste pelo menos estas invocações:

```text
/brain-flows:brainstorming
/brain-flows:flow
/brain-flows:flow-init
/brain-flows:writing-plan
/brain-flows:executing-plan
```

Depois de publicar o repositório no GitHub, o usuário poderá instalar com:

```text
/plugin marketplace add ANL-Software/brain-flows-marketplace
/plugin install brain-flows@anl-skills
```

## 6. Enviar ao marketplace público do Claude Code

Existem dois níveis de distribuição:

### Marketplace próprio

É imediato e não depende de revisão da Anthropic. Basta hospedar o repositório e compartilhar os comandos de instalação.

### Marketplace público da comunidade

Para solicitar inclusão pública:

1. Deixe o repositório e a documentação prontos para terceiros.
2. Adicione licença, instruções de instalação, exemplos e canal de suporte.
3. Execute `claude plugin validate .`.
4. Envie pelo [formulário de plugins do Claude Console](https://platform.claude.com/plugins/submit).
5. Aguarde a revisão e a inclusão no catálogo `claude-community`.

O marketplace `claude-plugins-official` é curado separadamente pela Anthropic. Não existe um processo comum de candidatura que garanta entrada nele.

Referências oficiais:

- [Criar plugins no Claude Code](https://code.claude.com/docs/en/plugins)
- [Criar e distribuir um marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
- [Descobrir e instalar plugins](https://code.claude.com/docs/en/discover-plugins)

## 7. Criar o plugin do Codex

Crie `plugins/brain-flows/.codex-plugin/plugin.json`:

```json
{
  "name": "brain-flows",
  "version": "1.0.0",
  "description": "Brainstorming, documentação de flows, planejamento e execução estruturada de mudanças.",
  "author": {
    "name": "ANL Software"
  },
  "homepage": "https://github.com/ANL-Software/brain-flows-marketplace",
  "repository": "https://github.com/ANL-Software/brain-flows-marketplace",
  "license": "MIT",
  "keywords": [
    "brainstorming",
    "planning",
    "documentation",
    "workflow"
  ],
  "skills": "./skills/",
  "interface": {
    "displayName": "Brain Flows",
    "shortDescription": "Planeje, documente e execute mudanças com rastreabilidade.",
    "longDescription": "Workflow integrado para explorar mudanças, documentar features, criar planos e executar a implementação com progresso rastreável.",
    "developerName": "ANL Software",
    "category": "Developer Tools",
    "capabilities": [
      "Read",
      "Write"
    ],
    "defaultPrompt": [
      "Use brainstorming para explorar o design desta feature.",
      "Mapeie o fluxo desta funcionalidade de ponta a ponta.",
      "Crie um plano de implementação para esta mudança."
    ]
  }
}
```

Para uma submissão pública, adicione também os campos visuais e legais apropriados, como `websiteURL`, `privacyPolicyURL`, `termsOfServiceURL`, `composerIcon`, `logo` e `screenshots`.

## 8. Criar o marketplace de repositório do Codex

Crie `.agents/plugins/marketplace.json` na raiz do repositório:

```json
{
  "name": "anl-skills",
  "interface": {
    "displayName": "ANL Skills"
  },
  "plugins": [
    {
      "name": "brain-flows",
      "source": {
        "source": "local",
        "path": "./plugins/brain-flows"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Developer Tools"
    }
  ]
}
```

O caminho é resolvido a partir da raiz do marketplace, deve começar com `./` e permanecer dentro do próprio repositório.

## 9. Adicionar e testar o marketplace no Codex

Para adicionar um marketplace local:

```bash
codex plugin marketplace add ./caminho/para/brain-flows-marketplace
```

Para adicionar pelo GitHub:

```bash
codex plugin marketplace add ANL-Software/brain-flows-marketplace
```

Para inspecionar ou atualizar:

```bash
codex plugin marketplace list
codex plugin marketplace upgrade anl-skills
```

No aplicativo desktop do ChatGPT, abra o diretório de Plugins, selecione `ANL Skills`, instale `Brain Flows` e inicie uma nova tarefa. No Codex CLI ou IDE, digite `$` para localizar e mencionar uma skill explicitamente. O Codex também pode ativar a skill implicitamente quando o pedido corresponder à sua `description`.

## 10. Enviar ao diretório público do Codex/OpenAI

O Codex aceita plugins somente de skills, sem exigir MCP. Para fazer a submissão pública:

1. Entre na organização publicadora na OpenAI Platform.
2. Garanta que o responsável tenha a permissão **Apps Management: Write**.
3. Verifique a identidade individual ou empresarial que aparecerá como publicadora.
4. Prepare os materiais da listagem:
   - nome, descrição curta e descrição longa;
   - logo e categoria;
   - site público;
   - URL de suporte;
   - política de privacidade;
   - termos de serviço;
   - países ou regiões disponíveis;
   - notas da versão.
5. Gere o bundle ou ZIP final preservando a árvore das cinco skills.
6. Prepare starter prompts que demonstrem os principais workflows.
7. Prepare exatamente cinco testes positivos e três testes negativos, cada um com prompt, comportamento esperado e formato do resultado.
8. Abra o [portal de submissão de plugins da OpenAI](https://platform.openai.com/apps).
9. Selecione **Create plugin** e depois **Skills only**.
10. Preencha a listagem, envie o bundle, cadastre prompts e testes e conclua as declarações de política.
11. Selecione **Submit for Review**.
12. Após a aprovação, escolha quando publicar pelo próprio portal.

Depois da publicação, o plugin aparece no diretório universal de plugins disponível no ChatGPT e no Codex.

Os arquivos `evals/evals.json` já existentes nas cinco skills podem servir de ponto de partida para os cinco casos positivos e três negativos exigidos. Adapte-os para que revisores externos consigam executar os cenários sem conhecimento interno do repositório.

Referências oficiais:

- [Criar skills para o Codex](https://learn.chatgpt.com/docs/build-skills)
- [Criar plugins para o Codex](https://learn.chatgpt.com/docs/build-plugins)
- [Enviar plugins para revisão](https://learn.chatgpt.com/docs/submit-plugins)

## 11. Versionamento e manutenção

Adote uma versão única para os manifests do Claude e do Codex:

1. Edite somente `.claude/skills/<skill>/` neste repositório.
2. Rode os testes e evals das skills alteradas.
3. Execute o script de empacotamento para atualizar o plugin público.
4. Confira que nenhuma referência aponta para arquivos externos ao diretório do plugin.
5. Atualize a versão em `.claude-plugin/plugin.json` e `.codex-plugin/plugin.json`.
6. Registre as mudanças no changelog ou nas release notes.
7. Valide os manifests.
8. Crie uma tag Git e publique a release.
9. Atualize as submissões oficiais quando a mudança precisar ser distribuída pelos diretórios públicos.

## Checklist final

- [ ] As cinco skills foram revisadas para Claude Code e Codex.
- [ ] `.claude/skills/` continua sendo a única fonte editável.
- [ ] O pacote público é gerado automaticamente, não mantido por cópia manual.
- [ ] O plugin não referencia arquivos fora de seu próprio diretório.
- [ ] Os dois `plugin.json` usam o mesmo nome e a mesma versão.
- [ ] Os dois marketplaces apontam para `./plugins/brain-flows`.
- [ ] `README.md`, licença, suporte, privacidade e termos estão publicados.
- [ ] O marketplace e o plugin do Claude passam em `claude plugin validate`.
- [ ] As cinco skills aparecem e podem ser invocadas no Claude Code.
- [ ] As cinco skills aparecem no Codex/ChatGPT desktop.
- [ ] Existem cinco testes positivos e três negativos reproduzíveis.
- [ ] O repositório público não contém credenciais, dados internos ou arquivos desnecessários.
