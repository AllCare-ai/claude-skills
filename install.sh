#!/usr/bin/env bash
set -euo pipefail

# Claude Skills Installer
# Usage:
#   Install all skills:  curl -fsSL https://raw.githubusercontent.com/ramybarsoum/claude-skills/main/install.sh | bash
#   Install one skill:   curl -fsSL https://raw.githubusercontent.com/ramybarsoum/claude-skills/main/install.sh | bash -s -- feature-spec-interview

REPO="ramybarsoum/claude-skills"
BRANCH="main"
SKILLS_DIR="${HOME}/.claude/skills"
TEMP_DIR=$(mktemp -d)

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# Version check mode
if [ "${1:-}" = "--check" ]; then
  echo "==> Checking for updates..."
  INSTALLED_DIR="${SKILLS_DIR}/feature-spec-interview"
  if [ ! -d "$INSTALLED_DIR" ]; then
    echo "  feature-spec-interview is not installed. Run without --check to install."
    exit 0
  fi
  # Compare file sizes as a simple version proxy
  LOCAL_SIZE=$(wc -c < "${INSTALLED_DIR}/SKILL.md" 2>/dev/null || echo "0")
  REMOTE_SIZE=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/${BRANCH}/skills/feature-spec-interview/SKILL.md" 2>/dev/null | wc -c || echo "0")
  if [ "$LOCAL_SIZE" != "$REMOTE_SIZE" ]; then
    echo "  Update available! Your SKILL.md is ${LOCAL_SIZE} bytes, latest is ${REMOTE_SIZE} bytes."
    echo "  Run: curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash"
  else
    echo "  You're up to date."
  fi
  exit 0
fi

echo "==> Downloading skills from github.com/${REPO}..."
curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR"

SOURCE_DIR="${TEMP_DIR}/claude-skills-${BRANCH}/skills"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: skills/ directory not found in repo."
  exit 1
fi

mkdir -p "$SKILLS_DIR"

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
  echo "  Done: ${skill_name}"
}

if [ $# -gt 0 ]; then
  # Install specific skills
  for skill in "$@"; do
    install_skill "$skill"
  done
else
  # Install all skills
  echo "Installing all skills..."
  for skill_dir in "$SOURCE_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    install_skill "$skill_name"
  done
fi

echo ""
echo "==> Skills installed to ${SKILLS_DIR}"
echo "    Restart Claude Code to pick up new skills."
echo "    Use /feature-spec-interview (or any skill name) to run."
