#!/usr/bin/env bash
# Distribui as cinco skills locais de .claude/skills/ para os espelhos por
# plataforma e para o diretório distribuível do plugin.
#
# .claude/skills/ é a fonte de verdade da edição local; sync-brain.sh só
# atualiza .claude/ e .agents/ a partir do repositório remoto, então .github/
# depende deste script para não ficar defasado.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS_DIR="$SCRIPT_DIR/.claude/skills"
BRAIN_SKILLS=(brainstorming flow flow-init writing-plan executing-plan)
TARGET_SKILLS_DIRS=(
  "$SCRIPT_DIR/.agents/skills"
  "$SCRIPT_DIR/.github/skills"
  "$SCRIPT_DIR/plugins/brain-flows/skills"
)
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

for target_skills_dir in "${TARGET_SKILLS_DIRS[@]}"; do
  mkdir -p "$target_skills_dir"
  rsync -a --delete "$STAGING_DIR/" "$target_skills_dir/"
  echo "  ✅ ${target_skills_dir#"$SCRIPT_DIR/"}"
done

echo "📦 Skills distribuídas a partir de .claude/skills/."
