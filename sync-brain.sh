#!/usr/bin/env bash
# Sincroniza as cinco skills do Brain Flows a partir da fonte local
# `.claude/skills/` para os espelhos e para o plugin distribuível.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRAIN_SKILLS=(brainstorming flow flow-init writing-plan executing-plan)

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

echo "🗂️  Verificando estrutura antiga..."
migrate_root_dir_to_docs "plan"
migrate_root_dir_to_docs "flow"

echo "📁 Sincronizando espelhos das skills..."
for skill in "${BRAIN_SKILLS[@]}"; do
  source_dir="$SCRIPT_DIR/.claude/skills/$skill"

  if [ ! -f "$source_dir/SKILL.md" ]; then
    echo "  ❌ Fonte ausente: .claude/skills/$skill/SKILL.md" >&2
    exit 1
  fi

  for mirror_root in .github/skills .agents/skills; do
    target_dir="$SCRIPT_DIR/$mirror_root/$skill"
    mkdir -p "$target_dir"
    rsync -a --delete "$source_dir/" "$target_dir/"
  done

  echo "  ✅ $skill"
done

"$SCRIPT_DIR/package-brain.sh"

echo "✅ Brain Flows sincronizado. Edite somente .claude/skills/."
