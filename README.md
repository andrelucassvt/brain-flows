# Brain Flows

A workflow for turning software changes into a clear, documented process that is easy to resume.

Brain Flows helps the agent understand the project before changing code, document how each feature works, validate the solution with you, create a plan, and execute it one step at a time.

![Brain Flows journey: map, understand, approve, plan, and execute](docs/assets/brain-flows-workflow-minimal.png)

## Why use it?

For larger changes, it is common to start implementing too early and later discover that an important rule, dependency, or file was overlooked. Brain Flows reduces this risk by keeping context and progress in documents versioned alongside the code.

In practice, it helps you:

- understand a project without rereading the entire codebase for every task;
- document the complete path of a feature;
- discuss and approve the solution before implementation;
- break the change into small, verifiable steps;
- resume work from the last completed step;
- keep documentation aligned with the code.

## How the workflow works

The process consists of an initial setup and a cycle used for each change.

### 1. Understand the project with `flow-init`

Use it once when you begin working on a project that does not yet have any flows.

`flow-init` analyzes the repository's actual structure and creates `docs/flow/project-structure.md` with the stack, architecture, modules, features, and configurations it finds. It can also generate individual flows or a list of suggestions to document later.

```text
Use flow-init to map this project.
```

### 2. Map features with `flow`

A flow is a snapshot of how a feature works from end to end.

The `flow` skill follows the actual path through the code—for example, from the UI to state, domain, repository, API, or database—and records it in `docs/flow/<name>.md`:

- the execution order;
- the files and responsibilities involved;
- the business rules;
- existing alternative paths and errors;
- relevant external dependencies.

```text
Map the login flow for this project.
```

### 3. Understand the change with `brainstorming`

Before implementing a creative or structural change, `brainstorming` clarifies the goal, reads the related flows, and compares possible solutions.

The result is a clearly explained design proposal. Implementation only moves forward after your approval. On approval it emits a compact **handoff block**—the approved decision, discarded alternatives, change type, key files, and affected flows—so the design survives into the next step even if the conversation context is compacted.

```text
Use brainstorming to explore adding social login.
```

### 4. Create the plan with `writing-plan`

After the design is approved, `writing-plan` turns the proposal into an actionable file inside `docs/plan/`.

The plan records:

- the goal and context;
- the **design of origin** (the approved decision and discarded alternatives, absorbed from the brainstorming handoff), so the plan is self-contained;
- files that will be changed;
- phases and checkboxes;
- verification steps and success criteria;
- risks and rollback strategy;
- related flows that will need to be updated.

```text
Create a plan to implement the approved design.
```

### 5. Execute with `executing-plan`

`executing-plan` reviews the plan against the current state of the repository and executes one task at a time.

It uses the plan's **design of origin** as the boundary for handling code drift: a fix that reintroduces a discarded alternative is treated as a new decision that needs your approval, not a mechanical correction. Each checkbox is marked only after the corresponding verification. If the work is interrupted, execution can resume from the first pending item. At the end, affected flows are updated—and linked back to the plan—whenever the documented structure or behavior has changed.

```text
Execute the social login plan.
```

### Optional: run the whole cycle unattended with the `brain-agent-loop` agent

`brain-agent-loop` orchestrates the same chain without editing any of the three skills above. It only activates when you explicitly ask for full autonomy through the whole cycle, with no approval at any point — otherwise the normal pauses apply.

It skips every confirmation, including design approval: when there's more than one plausible option, the agent picks the recommended one itself, records why, and moves straight through `writing-plan` and `executing-plan` to a finished result. Real capability limits (a missing credential, an external dependency that can't be created) still exist, but instead of stopping to ask permission, the agent picks the most reasonable path and reports the limitation in the final summary.

`brain-agent-loop` is not a skill and is not installed by the plugin. It's a local Claude Code subagent (`.claude/agents/brain-agent-loop.md`) that runs with `permissionMode: bypassPermissions`, so it also skips tool-confirmation prompts; `sync-brain.sh` fetches it into your project's `.claude/agents/` alongside the skills. It isn't available in Codex: plugin subagents ignore `permissionMode`, and Codex has no equivalent to a subagent with its own permission mode.

Because it skips tool-confirmation prompts, it never works directly on the branch you had checked out: it opens an isolated worktree before starting, and finishes by committing, pushing, and opening a Pull Request — never an automatic merge. If it can't open a PR (no remote, `gh` not authenticated), it reports that as a capability limit and leaves the work committed in the worktree instead.

```text
I don't want any human approval in this — pick the best design yourself and keep implementing without interruptions until it's done.
```

## Overview

```text
Project setup
flow-init ──> project-structure.md ──> feature flows

Change cycle
brainstorming ──> approval ──> writing-plan ──> executing-plan ──> updated flow
             (handoff)      (design of origin)   (defends design,
                                                   links flow back)
```

Each arrow is an explicit handoff: the approved design travels forward as a handoff block, gets recorded inside the plan as its "design of origin", and is defended during execution—so no step depends on conversation history that may have been compacted.

The Markdown files serve as the process's shared memory:

```text
docs/
├── flow/
│   ├── project-structure.md
│   └── login.md
└── plan/
    └── login-social.md
```

## Which skill should I use?

| When you need to... | Use |
|---|---|
| Map the entire project for the first time | `flow-init` |
| Understand or document an existing feature | `flow` |
| Explore a change and decide how to implement it | `brainstorming` |
| Turn an approved design into actionable steps | `writing-plan` |
| Implement or resume an existing plan | `executing-plan` |
| Run the whole cycle unattended, no approval at all | `brain-agent-loop` agent (local, not a skill) |

You do not need to run every skill for every task. A small mechanical fix can be made directly, while a larger feature benefits from the full cycle.

## Installation in Claude Code

```text
/plugin marketplace add andrelucassvt/brain-flows
/plugin install brain-flows@brain-flows
/reload-plugins
```

Invoke the skills with `/brain-flows:brainstorming`, `/brain-flows:flow`, `/brain-flows:flow-init`, `/brain-flows:writing-plan`, or `/brain-flows:executing-plan`.

## Installation in Codex

```bash
codex plugin marketplace add andrelucassvt/brain-flows
```

In the Codex CLI or IDE, type `$` to select a skill or explicitly mention its name in the prompt. In the app, open the Plugins directory, select the **Brain Flows** marketplace, and install the **Brain Flows** plugin.

## Development and packaging

The default source repository is `https://github.com/andrelucassvt/brain-flows`, on the `main` branch. Synchronization reads the skills from `plugins/brain-flows/skills/` and copies only the five Brain Flows skills to `.claude/skills/`, `.agents/skills/`, and `.github/skills/`.

```bash
./sync-brain.sh
```

To use a different source or branch without editing the script:

```bash
SOURCE_REPO=https://github.com/organization/repository.git SOURCE_BRANCH=develop SOURCE_SKILLS_PATH=plugins/brain-flows/skills ./sync-brain.sh
```

To recreate `plugins/brain-flows/skills/` from `.claude/skills/`, run:

```bash
./package-brain.sh
```

Before a release, keep the same version in both `plugin.json` files, run the platform validators, and record the change in `CHANGELOG.md`.

### Local validation

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

## Support and policies

- [Support](SUPPORT.md)
- [Privacy Policy](PRIVACY.md)
- [Terms of Use](TERMS.md)
- [MIT License](LICENSE)
