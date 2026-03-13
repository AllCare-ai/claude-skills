#!/usr/bin/env bash
set -euo pipefail

# Claude Skills Installer
# Usage:
#   Install all:     curl -fsSL https://raw.githubusercontent.com/ramybarsoum/claude-skills/main/install.sh | bash
#   Install one:     curl -fsSL https://raw.githubusercontent.com/ramybarsoum/claude-skills/main/install.sh | bash -s -- feature-spec-interview
#   Check updates:   curl -fsSL https://raw.githubusercontent.com/ramybarsoum/claude-skills/main/install.sh | bash -s -- --check
#   Uninstall:       curl -fsSL https://raw.githubusercontent.com/ramybarsoum/claude-skills/main/install.sh | bash -s -- --uninstall

REPO="ramybarsoum/claude-skills"
BRANCH="main"
SKILLS_DIR="${HOME}/.claude/skills"
HOOKS_DIR="${HOME}/.claude"
HOOKS_FILE="${HOOKS_DIR}/hooks.json"
TEMP_DIR=$(mktemp -d)

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# ─── Version check ───────────────────────────────────────────────
if [ "${1:-}" = "--check" ]; then
  echo "==> Checking for updates..."
  INSTALLED_DIR="${SKILLS_DIR}/feature-spec-interview"
  if [ ! -d "$INSTALLED_DIR" ]; then
    echo "  feature-spec-interview is not installed. Run without --check to install."
    exit 0
  fi
  LOCAL_SIZE=$(wc -c < "${INSTALLED_DIR}/SKILL.md" 2>/dev/null | tr -d ' ' || echo "0")
  REMOTE_SIZE=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/${BRANCH}/skills/feature-spec-interview/SKILL.md" 2>/dev/null | wc -c | tr -d ' ' || echo "0")
  if [ "$LOCAL_SIZE" != "$REMOTE_SIZE" ]; then
    echo "  Update available! Run the install command to update."
    echo "  curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash"
  else
    echo "  You're up to date."
  fi
  exit 0
fi

# ─── Uninstall ───────────────────────────────────────────────────
if [ "${1:-}" = "--uninstall" ]; then
  echo "==> Uninstalling claude-skills..."
  if [ -d "${SKILLS_DIR}/feature-spec-interview" ]; then
    rm -rf "${SKILLS_DIR}/feature-spec-interview"
    echo "  Removed feature-spec-interview skill"
  fi
  # Remove hook entry from hooks.json if present
  if [ -f "$HOOKS_FILE" ] && command -v python3 &>/dev/null; then
    python3 -c "
import json, sys
try:
    with open('$HOOKS_FILE') as f:
        data = json.load(f)
    hooks = data.get('hooks', {}).get('user-prompt-submit', [])
    data['hooks']['user-prompt-submit'] = [h for h in hooks if 'suggest-skill.sh' not in h.get('command', '')]
    if not data['hooks']['user-prompt-submit']:
        del data['hooks']['user-prompt-submit']
    if not data['hooks']:
        del data['hooks']
    with open('$HOOKS_FILE', 'w') as f:
        json.dump(data, f, indent=2)
    print('  Removed hook from hooks.json')
except Exception:
    pass
" 2>/dev/null || true
  fi
  echo "  Done. Restart Claude Code."
  exit 0
fi

# ─── Download ────────────────────────────────────────────────────
echo ""
echo "  ┌─────────────────────────────────────┐"
echo "  │  Claude Skills Installer             │"
echo "  │  github.com/${REPO}  │"
echo "  └─────────────────────────────────────┘"
echo ""
echo "==> Downloading skills..."
curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR"

SOURCE_DIR="${TEMP_DIR}/claude-skills-${BRANCH}/skills"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: skills/ directory not found in repo."
  exit 1
fi

mkdir -p "$SKILLS_DIR"

# ─── Install skills ──────────────────────────────────────────────
install_skill() {
  local skill_name="$1"
  local src="${SOURCE_DIR}/${skill_name}"

  if [ ! -d "$src" ]; then
    echo "Error: skill '${skill_name}' not found in repo."
    echo "Available skills:"
    ls "$SOURCE_DIR" 2>/dev/null | sed 's/^/  - /'
    return 1
  fi

  if [ -d "${SKILLS_DIR}/${skill_name}" ]; then
    echo "  Updating ${skill_name}..."
    rm -rf "${SKILLS_DIR}/${skill_name}"
  else
    echo "  Installing ${skill_name}..."
  fi

  cp -r "$src" "${SKILLS_DIR}/${skill_name}"
  # Make hook scripts executable
  find "${SKILLS_DIR}/${skill_name}" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
  echo "  Done: ${skill_name}"
}

if [ $# -gt 0 ]; then
  for skill in "$@"; do
    install_skill "$skill"
  done
else
  echo "Installing all skills..."
  for skill_dir in "$SOURCE_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    install_skill "$skill_name"
  done
fi

# ─── Auto-configure hooks ────────────────────────────────────────
echo ""
echo "==> Configuring hooks..."

HOOK_CMD="${SKILLS_DIR}/feature-spec-interview/hooks/suggest-skill.sh"

if [ -f "$HOOK_CMD" ]; then
  mkdir -p "$HOOKS_DIR"

  if command -v python3 &>/dev/null; then
    python3 -c "
import json, os, sys

hooks_file = '$HOOKS_FILE'
hook_cmd = '$HOOK_CMD'
hook_entry = {
    'command': hook_cmd,
    'description': 'Suggest feature-spec-interview for spec writing tasks'
}

# Load existing or create new
if os.path.exists(hooks_file):
    with open(hooks_file) as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            data = {}
else:
    data = {}

# Ensure structure exists
if 'hooks' not in data:
    data['hooks'] = {}
if 'user-prompt-submit' not in data['hooks']:
    data['hooks']['user-prompt-submit'] = []

# Check if hook already registered
existing = data['hooks']['user-prompt-submit']
already_installed = any('suggest-skill.sh' in h.get('command', '') for h in existing)

if not already_installed:
    existing.append(hook_entry)
    with open(hooks_file, 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
    print('  Hook registered in ~/.claude/hooks.json')
else:
    print('  Hook already registered (skipped)')
" 2>/dev/null
  else
    # Fallback: no python3, write hooks.json directly if it doesn't exist
    if [ ! -f "$HOOKS_FILE" ]; then
      cat > "$HOOKS_FILE" << HOOKEOF
{
  "hooks": {
    "user-prompt-submit": [
      {
        "command": "${HOOK_CMD}",
        "description": "Suggest feature-spec-interview for spec writing tasks"
      }
    ]
  }
}
HOOKEOF
      echo "  Hook registered in ~/.claude/hooks.json"
    else
      echo "  hooks.json exists but python3 not available for safe merge."
      echo "  See: ~/.claude/skills/feature-spec-interview/hooks/README.md"
    fi
  fi
else
  echo "  No hooks to configure."
fi

# ─── Done ────────────────────────────────────────────────────────
echo ""
echo "==> All done!"
echo ""
echo "  Skills installed to: ${SKILLS_DIR}"
echo "  Hooks configured at: ${HOOKS_FILE}"
echo ""
echo "  Available commands:"
echo "    /feature-spec-interview    Run the NLSpec interview"
echo ""
echo "  Modes: All | PM-first | Eng-first | Fill-gaps | Quick"
echo ""
echo "  Check for updates:  curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash -s -- --check"
echo "  Uninstall:          curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash -s -- --uninstall"
echo ""
echo "  Restart Claude Code to pick up the new skill."
