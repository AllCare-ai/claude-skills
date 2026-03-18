#!/usr/bin/env bash
set -euo pipefail

# Claude Skills Installer
# Usage:
#   Install all:     curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash
#   Install one:     curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash -s -- feature-spec-interview
#   Install group:   curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash -s -- --group coding
#   Check updates:   curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash -s -- --check
#   Uninstall:       curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash -s -- --uninstall
#   List groups:     curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash -s -- --list

REPO="AllCare-ai/claude-skills"
BRANCH="main"
SKILLS_DIR="${HOME}/.claude/skills"
HOOKS_DIR="${HOME}/.claude"
HOOKS_FILE="${HOOKS_DIR}/hooks.json"
TEMP_DIR=$(mktemp -d)

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# ─── List groups ──────────────────────────────────────────────
if [ "${1:-}" = "--list" ]; then
  echo ""
  echo "  Available skill groups:"
  echo ""
  echo "    product-and-specs    Spec writing, planning, marketing, launch (16 skills)"
  echo "    coding               Code quality, review, testing, debugging, git (27 skills)"
  echo "    ui-ux-design         Frontend, components, diagrams, browser automation (17 skills)"
  echo "    ai-and-agents        SDK, MCP, orchestration, memory, optimization (11 skills)"
  echo "    mobile-and-native    Swift, SwiftUI, iOS, Expo (14 skills)"
  echo "    documents-and-files  PDF, DOCX, PPTX, XLSX, GIF (5 skills)"
  echo "    workflow-and-meta    Skills that modify Claude Code itself (11 skills)"
  echo ""
  echo "  Install a group:"
  echo "    curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash -s -- --group coding"
  echo ""
  exit 0
fi

# ─── Version check ───────────────────────────────────────────────
if [ "${1:-}" = "--check" ]; then
  echo "==> Checking for updates..."
  INSTALLED_DIR="${SKILLS_DIR}/feature-spec-interview"
  if [ ! -d "$INSTALLED_DIR" ]; then
    echo "  feature-spec-interview is not installed. Run without --check to install."
    exit 0
  fi
  LOCAL_SIZE=$(wc -c < "${INSTALLED_DIR}/SKILL.md" 2>/dev/null | tr -d ' ' || echo "0")
  REMOTE_SIZE=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/${BRANCH}/skills/product-and-specs/feature-spec-interview/SKILL.md" 2>/dev/null | wc -c | tr -d ' ' || echo "0")
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
  # Remove all known skills installed by this repo
  REMOVED=0
  if [ -f "$TEMP_DIR/.uninstall_attempted" ] 2>/dev/null; then true; fi
  # Download repo to get skill list
  curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR" 2>/dev/null || true
  SOURCE_DIR="${TEMP_DIR}/claude-skills-${BRANCH}/skills"
  if [ -d "$SOURCE_DIR" ]; then
    for group_dir in "$SOURCE_DIR"/*/; do
      for skill_dir in "$group_dir"*/; do
        skill_name=$(basename "$skill_dir")
        if [ -d "${SKILLS_DIR}/${skill_name}" ]; then
          rm -rf "${SKILLS_DIR}/${skill_name}"
          echo "  Removed ${skill_name}"
          REMOVED=$((REMOVED + 1))
        fi
      done
    done
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
  echo "  Removed ${REMOVED} skills. Restart Claude Code."
  exit 0
fi

# ─── Download ────────────────────────────────────────────────────
echo ""
echo "  ┌─────────────────────────────────────┐"
echo "  │  Claude Skills Installer             │"
echo "  │  github.com/${REPO}     │"
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

# ─── Install skill ──────────────────────────────────────────────
install_skill() {
  local skill_name="$1"
  local src="$2"

  if [ -d "${SKILLS_DIR}/${skill_name}" ]; then
    echo "  Updating ${skill_name}..."
    rm -rf "${SKILLS_DIR}/${skill_name}"
  else
    echo "  Installing ${skill_name}..."
  fi

  cp -r "$src" "${SKILLS_DIR}/${skill_name}"
  # Make hook scripts executable
  find "${SKILLS_DIR}/${skill_name}" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
}

# ─── Find a skill by name across all groups ─────────────────────
find_skill() {
  local name="$1"
  for group_dir in "$SOURCE_DIR"/*/; do
    if [ -d "${group_dir}${name}" ]; then
      echo "${group_dir}${name}"
      return 0
    fi
  done
  return 1
}

# ─── Install by group ───────────────────────────────────────────
if [ "${1:-}" = "--group" ]; then
  GROUP="${2:-}"
  if [ -z "$GROUP" ]; then
    echo "Error: specify a group name. Run with --list to see available groups."
    exit 1
  fi
  GROUP_DIR="${SOURCE_DIR}/${GROUP}"
  if [ ! -d "$GROUP_DIR" ]; then
    echo "Error: group '${GROUP}' not found."
    echo "Available groups:"
    ls "$SOURCE_DIR" 2>/dev/null | sed 's/^/  - /'
    exit 1
  fi
  echo "Installing group: ${GROUP}"
  COUNT=0
  for skill_dir in "$GROUP_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    install_skill "$skill_name" "$skill_dir"
    COUNT=$((COUNT + 1))
  done
  echo ""
  echo "  Installed ${COUNT} skills from ${GROUP}."
# ─── Install specific skills by name ────────────────────────────
elif [ $# -gt 0 ]; then
  for skill in "$@"; do
    src=$(find_skill "$skill") || true
    if [ -z "$src" ]; then
      echo "Error: skill '${skill}' not found in any group."
      echo "Available groups:"
      ls "$SOURCE_DIR" 2>/dev/null | sed 's/^/  - /'
      continue
    fi
    install_skill "$skill" "$src"
  done
# ─── Install all ────────────────────────────────────────────────
else
  echo "Installing all skills..."
  COUNT=0
  for group_dir in "$SOURCE_DIR"/*/; do
    group_name=$(basename "$group_dir")
    echo ""
    echo "  ── ${group_name} ──"
    for skill_dir in "$group_dir"*/; do
      [ -d "$skill_dir" ] || continue
      skill_name=$(basename "$skill_dir")
      install_skill "$skill_name" "$skill_dir"
      COUNT=$((COUNT + 1))
    done
  done
  echo ""
  echo "  Installed ${COUNT} skills across $(ls -d "$SOURCE_DIR"/*/ | wc -l | tr -d ' ') groups."
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
echo "  Restart Claude Code, then type /find-skills to see everything."
echo ""
echo "  Popular skills:"
echo "    /feature-spec-interview    NLSpec interview for AI-executable specs"
echo "    /brainstorming             Structured creative exploration"
echo "    /frontend-design           Production-grade UI design"
echo "    /systematic-debugging      Scientific debugging workflow"
echo "    /test-driven-development   TDD workflow"
echo ""
echo "  Install a specific group:"
echo "    curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash -s -- --group coding"
echo ""
echo "  Check for updates:  curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash -s -- --check"
echo "  Uninstall:          curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash -s -- --uninstall"
echo "  List groups:        curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash -s -- --list"
echo ""
echo "  Restart Claude Code to pick up the new skills."
