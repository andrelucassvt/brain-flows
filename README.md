# Brain Flows Marketplace

Plugin de André Salvador para transformar mudanças de software em um processo rastreável de descoberta, documentação, planejamento e execução. O mesmo pacote funciona no Claude Code e no Codex.

## Skills incluídas

- `brainstorming` — explora requisitos e aprova o design antes da implementação.
- `flow` — documenta uma feature ou processo de ponta a ponta.
- `flow-init` — cria o mapa estrutural e o inventário inicial de flows.
- `writing-plan` — converte um design em plano executável.
- `executing-plan` — executa e atualiza o progresso de um plano existente.

## Instalação no Claude Code

```text
/plugin marketplace add ANL-Software/brain-flows-marketplace
/plugin install brain-flows@anl-skills
/reload-plugins
```

Invoque as skills com `/brain-flows:brainstorming`, `/brain-flows:flow`, `/brain-flows:flow-init`, `/brain-flows:writing-plan` ou `/brain-flows:executing-plan`.

## Instalação no Codex

```bash
codex plugin marketplace add ANL-Software/brain-flows-marketplace
```

No Codex CLI ou IDE, digite `$` para selecionar uma skill ou mencione seu nome explicitamente no prompt. No aplicativo, abra o diretório de Plugins, selecione **ANL Skills** e instale **Brain Flows**.

## Desenvolvimento e empacotamento

Edite somente `.claude/skills/<skill>/`. Os diretórios `.github/skills/`, `.agents/skills/` e `plugins/brain-flows/skills/` são artefatos gerados.

```bash
./sync-brain.sh
```

O comando atualiza os dois espelhos e empacota somente as cinco skills declaradas em `BRAIN_SKILLS`. Para atualizar apenas o plugin distribuível, execute `./package-brain.sh`.

Antes de uma release, mantenha a mesma versão nos dois `plugin.json`, execute os validadores das plataformas e registre a mudança no `CHANGELOG.md`.

## Desenvolvimento local

Claude Code:

```bash
claude plugin validate .
claude plugin validate ./plugins/brain-flows
```

Codex:

```bash
codex plugin marketplace add "$PWD"
codex plugin marketplace list
```

## Suporte e políticas

- [Suporte](SUPPORT.md)
- [Política de privacidade](PRIVACY.md)
- [Termos de uso](TERMS.md)
- [Licença MIT](LICENSE)
