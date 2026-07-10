#!/usr/bin/env bash
# Busca as cinco skills do Brain Flows no repositório-fonte e as instala em:
#   .claude/skills/
#   .agents/skills/
#   .github/skills/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_REPO="${SOURCE_REPO:-https://github.com/andrelucassvt/brain-flows.git}"
SOURCE_BRANCH="${SOURCE_BRANCH:-master}"
SOURCE_SKILLS_PATH="${SOURCE_SKILLS_PATH:-plugins/brain-flows/skills}"
BRAIN_SKILLS=(brainstorming flow flow-init writing-plan executing-plan)
TARGET_SKILLS_DIRS=(
  "$SCRIPT_DIR/.claude/skills"
  "$SCRIPT_DIR/.agents/skills"
  "$SCRIPT_DIR/.github/skills"
)

TMP_DIR="$(mktemp -d)"
SOURCE_DIR="$TMP_DIR/source"
STAGING_DIR="$TMP_DIR/skills"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "⬇️  Buscando skills de $SOURCE_REPO ($SOURCE_BRANCH:$SOURCE_SKILLS_PATH)..."
git clone --depth 1 --branch "$SOURCE_BRANCH" "$SOURCE_REPO" "$SOURCE_DIR" --quiet

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
