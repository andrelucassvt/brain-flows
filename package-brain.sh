#!/usr/bin/env bash
# Empacota somente as seis skills locais no diretório distribuível do plugin.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS_DIR="$SCRIPT_DIR/.claude/skills"
PLUGIN_SKILLS_DIR="$SCRIPT_DIR/plugins/brain-flows/skills"
BRAIN_SKILLS=(agent-loop brainstorming flow flow-init writing-plan executing-plan)
STAGING_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$STAGING_DIR"
}
trap cleanup EXIT

for skill in "${BRAIN_SKILLS[@]}"; do
  source_skill_dir="$SOURCE_SKILLS_DIR/$skill"
  staging_skill_dir="$STAGING_DIR/$skill"

  if [ ! -f "$source_skill_dir/SKILL.md" ]; then
    echo "Fonte ausente: .claude/skills/$skill/SKILL.md" >&2
    echo "Execute ./sync-brain.sh antes de empacotar." >&2
    exit 1
  fi

  mkdir -p "$staging_skill_dir"
  rsync -a --delete "$source_skill_dir/" "$staging_skill_dir/"
done

mkdir -p "$PLUGIN_SKILLS_DIR"
rsync -a --delete "$STAGING_DIR/" "$PLUGIN_SKILLS_DIR/"

echo "📦 Plugin atualizado em plugins/brain-flows/skills/."
