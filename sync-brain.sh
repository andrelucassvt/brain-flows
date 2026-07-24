#!/usr/bin/env bash
# Busca as cinco skills do Brain Flows no repositório-fonte e as instala em:
#   .claude/skills/
#   .agents/skills/
#   .github/skills/
# Também busca os agentes locais (ex.: agent-loop) direto de .claude/agents/
# no repositório-fonte e os instala em .claude/agents/ — não passam pelo
# plugin, porque subagents de plugin ignoram o campo permissionMode.
#   chmod +x sync-brain.sh
#   ./sync-brain.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SOURCE_REPO="${SOURCE_REPO:-https://github.com/andrelucassvt/brain-flows.git}"
SOURCE_BRANCH="${SOURCE_BRANCH:-main}"
SOURCE_SKILLS_PATH="${SOURCE_SKILLS_PATH:-plugins/brain-flows/skills}"
SOURCE_AGENTS_PATH="${SOURCE_AGENTS_PATH:-.claude/agents}"
BRAIN_SKILLS=(brainstorming flow flow-init writing-plan executing-plan)
BRAIN_AGENTS=(agent-loop)
TARGET_SKILLS_DIRS=(
  "$SCRIPT_DIR/.claude/skills"
  "$SCRIPT_DIR/.agents/skills"
  "$SCRIPT_DIR/.github/skills"
)
TARGET_AGENTS_DIR="$SCRIPT_DIR/.claude/agents"

TMP_DIR="$(mktemp -d)"
SOURCE_DIR="$TMP_DIR/source"
STAGING_DIR="$TMP_DIR/skills"
STAGING_AGENTS_DIR="$TMP_DIR/agents"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "⬇️  Buscando skills de $SOURCE_REPO ($SOURCE_BRANCH:$SOURCE_SKILLS_PATH)..."
git clone --depth 1 --branch "$SOURCE_BRANCH" "$SOURCE_REPO" "$SOURCE_DIR" --quiet

# ── Auto-atualização do script ─────────────────────────────
SCRIPT_SRC="$SOURCE_DIR/$SCRIPT_NAME"
if [ -f "$SCRIPT_SRC" ]; then
  if ! diff -q "$SCRIPT_SRC" "$SCRIPT_DIR/$SCRIPT_NAME" > /dev/null 2>&1; then
    echo "🔄 Nova versão do script encontrada. Atualizando e reiniciando..."
    cp "$SCRIPT_SRC" "$SCRIPT_DIR/$SCRIPT_NAME"
    chmod +x "$SCRIPT_DIR/$SCRIPT_NAME"
    cleanup
    trap - EXIT
    exec "$SCRIPT_DIR/$SCRIPT_NAME" "$@"
  fi
fi

echo "📁 Preparando as skills do Brain Flows..."
for skill in "${BRAIN_SKILLS[@]}"; do
  source_skill_dir="$SOURCE_DIR/$SOURCE_SKILLS_PATH/$skill"
  staging_skill_dir="$STAGING_DIR/$skill"

  if [ ! -f "$source_skill_dir/SKILL.md" ]; then
    echo "  ❌ Skill ausente no repositório-fonte: $SOURCE_SKILLS_PATH/$skill" >&2
    exit 1
  fi

  mkdir -p "$staging_skill_dir"
  rsync -a --delete "$source_skill_dir/" "$staging_skill_dir/"
  echo "  ✅ $skill"
done

echo "📥 Atualizando destinos locais..."
for target_skills_dir in "${TARGET_SKILLS_DIRS[@]}"; do
  mkdir -p "$target_skills_dir"

  for skill in "${BRAIN_SKILLS[@]}"; do
    mkdir -p "$target_skills_dir/$skill"
    rsync -a --delete "$STAGING_DIR/$skill/" "$target_skills_dir/$skill/"
  done

  echo "  ✅ ${target_skills_dir#"$SCRIPT_DIR/"}"
done

echo "✅ Brain Flows sincronizado em .claude/skills/, .agents/skills/ e .github/skills/."

echo "🤖 Preparando os agentes locais do Brain Flows..."
mkdir -p "$STAGING_AGENTS_DIR"
for agent in "${BRAIN_AGENTS[@]}"; do
  source_agent_file="$SOURCE_DIR/$SOURCE_AGENTS_PATH/$agent.md"

  if [ ! -f "$source_agent_file" ]; then
    echo "  ❌ Agente ausente no repositório-fonte: $SOURCE_AGENTS_PATH/$agent.md" >&2
    exit 1
  fi

  cp "$source_agent_file" "$STAGING_AGENTS_DIR/$agent.md"
  echo "  ✅ $agent"
done

mkdir -p "$TARGET_AGENTS_DIR"
for agent in "${BRAIN_AGENTS[@]}"; do
  cp "$STAGING_AGENTS_DIR/$agent.md" "$TARGET_AGENTS_DIR/$agent.md"
done

echo "✅ Agentes locais sincronizados em .claude/agents/ (não fazem parte do plugin)."

migrate_root_dir_to_docs() {
  local name="$1"
  local old_dir="$SCRIPT_DIR/$name"
  local new_dir="$SCRIPT_DIR/docs/$name"

  if [ -d "$old_dir" ]; then
    mkdir -p "$new_dir"
    rsync -a "$old_dir/" "$new_dir/"
    rm -rf "$old_dir"
    echo "  ✅ $name/ → docs/$name/"
  fi
}

echo "🗂️  Verificando estrutura antiga (plan/ e flow/ na raiz)..."
migrate_root_dir_to_docs "plan"
migrate_root_dir_to_docs "flow"
