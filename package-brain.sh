#!/usr/bin/env bash
# Gera o conteúdo distribuível de plugins/brain-flows/skills/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_SKILLS_DIR="$SCRIPT_DIR/plugins/brain-flows/skills"
BRAIN_SKILLS=(brainstorming flow flow-init writing-plan executing-plan)
STAGING_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$STAGING_DIR"
}
trap cleanup EXIT

for skill in "${BRAIN_SKILLS[@]}"; do
  source_dir="$SCRIPT_DIR/.claude/skills/$skill"
  staging_skill_dir="$STAGING_DIR/$skill"

  if [ ! -f "$source_dir/SKILL.md" ]; then
    echo "Fonte ausente: .claude/skills/$skill/SKILL.md" >&2
    exit 1
  fi

  mkdir -p "$staging_skill_dir"
  rsync -a --delete "$source_dir/" "$staging_skill_dir/"
done

mkdir -p "$PLUGIN_SKILLS_DIR"
rsync -a --delete "$STAGING_DIR/" "$PLUGIN_SKILLS_DIR/"

echo "📦 Plugin atualizado com ${#BRAIN_SKILLS[@]} skills em plugins/brain-flows/skills/."
