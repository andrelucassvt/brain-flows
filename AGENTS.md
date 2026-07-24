# Brain Flows

Marketplace/plugin de cinco skills em Markdown para desenvolvimento orientado por documentação, distribuído para Claude Code e Codex. Não é um app — não há código de aplicação para executar.

## Stack

- Skills em `SKILL.md` (frontmatter `name` + `description`)
- Automação em Bash (`sync-brain.sh`, `package-brain.sh`)
- Manifestos JSON de plugin/marketplace para Claude e Codex
- Ferramentas externas: `git`, `rsync`, `mktemp`

## Estrutura

- `plugins/brain-flows/skills/` — fonte canônica das skills empacotadas no plugin
- `.claude/skills/`, `.agents/skills/`, `.github/skills/` — espelhos por plataforma, idênticos entre si
- `plugins/brain-flows/.claude-plugin/plugin.json` e `.codex-plugin/plugin.json` — manifestos do plugin
- `.claude-plugin/marketplace.json` e `.agents/plugins/marketplace.json` — manifestos do marketplace
- `docs/flow/` — estrutura do projeto e flows individuais
- `submission/evals.json` — testes de acionamento das skills

## Agentes locais

- `.claude/agents/` guarda subagentes locais do Claude Code que não pertencem ao plugin distribuído — não são empacotados em `plugins/brain-flows/` nem instalados via marketplace.
- `brain-agent-loop` é um agente local (não skill): orquestra `brainstorming → writing-plan → executing-plan` sem nenhuma pausa de aprovação humana e roda com `permissionMode: bypassPermissions`. Fica fora do plugin porque subagents de plugin ignoram o campo `permissionMode`, e o Codex não tem equivalente a subagent com modo de permissão próprio.
- Mesmo fora do plugin, `brain-agent-loop` é sincronizado por `sync-brain.sh`: o script busca `.claude/agents/<agente>.md` direto do repositório-fonte (lista `BRAIN_AGENTS`) e copia para `.claude/agents/` local, sem passar por `plugins/brain-flows/`. `.claude/agents/` local É a fonte de verdade — editar ali direto, sem passo de empacotamento equivalente ao `package-brain.sh`.
- Só é sincronizado para `.claude/agents/` — não é espelhado em `.agents/skills/`, `.github/skills/` nem `plugins/brain-flows/skills/`, porque `permissionMode` é um conceito exclusivo do Claude Code.
- Novos agentes locais com `permissionMode: bypassPermissions` seguem o mesmo padrão: adicionar a `BRAIN_AGENTS` em `sync-brain.sh`, viver só em `.claude/agents/`, nunca dentro de `plugins/brain-flows/`.

## Comandos

- `./sync-brain.sh` — baixa as skills do repositório-fonte e distribui para os três diretórios locais; também baixa os agentes locais (`BRAIN_AGENTS`) direto de `.claude/agents/` do repositório-fonte para `.claude/agents/`
- `./package-brain.sh` — reconstrói `plugins/brain-flows/skills/` a partir de `.claude/skills/`
- `claude plugin validate .` e `claude plugin validate ./plugins/brain-flows` — validam no Claude Code
- `codex plugin marketplace add "$PWD"` — valida no Codex

## Convenções

- As cinco skills são fixas: `brainstorming`, `flow`, `flow-init`, `writing-plan`, `executing-plan`. Adicionar/remover exige atualizar a lista `BRAIN_SKILLS` em ambos os scripts.
- Edite as skills em `.claude/skills/<skill>/` e depois rode `./package-brain.sh` para propagar à fonte canônica; nunca edite só um dos espelhos.
- Mantenha a mesma `version` nos dois `plugin.json` (Claude e Codex).
- Registre mudanças relevantes em `CHANGELOG.md`.
- Idioma da documentação e das skills: Português (Brasil).

## Gotchas

- `rsync --delete` nos scripts espelha exatamente: arquivos removidos na fonte somem nos destinos.
- `sync-brain.sh` se auto-atualiza e reexecuta se detectar uma versão nova no repositório-fonte antes de sincronizar.
- Neste repositório, `SOURCE_REPO` aponta por padrão para o próprio `brain-flows` (dogfooding).
- O `.gitignore` ignora `.sync-brain.sh` (com ponto inicial), não o `sync-brain.sh` versionado.

## Não fazer

- Não edite apenas um dos diretórios de skills (`.claude`/`.agents`/`.github`/`plugins`) — eles devem ficar idênticos.
- Não altere versões nos manifestos sem também atualizar o `CHANGELOG.md`.
- Não introduza sintaxe exclusiva de plataforma nas instruções compartilhadas das skills.

## 📖 Documentação de Flows

Para qualquer feature ou fluxo, verifique a pasta `./docs/flow/`: leia os títulos dos arquivos `.md` disponíveis e, se algum for relevante para a tarefa atual, leia-o antes de implementar ou debugar. Invoque a skill `flow` para criar ou atualizar flows individuais.

## 🧪 Teste funcional

Após implementar, não execute o projeto para validar o resultado (rodar o app, emulador/simulador, dispositivo físico, servidor local, screenshots ou interação simulada). Teste funcional/visual é responsabilidade do usuário.

- Limite a verificação a análise estática, build/compile e testes automatizados
- Ao concluir, liste objetivamente o que o usuário deve testar manualmente
- Não pergunte se deve executar o projeto — só faça isso se o usuário pedir explicitamente
</content>
