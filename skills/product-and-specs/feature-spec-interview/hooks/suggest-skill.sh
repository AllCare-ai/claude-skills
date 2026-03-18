#!/usr/bin/env bash
# Hook: suggest feature-spec-interview skill when trigger phrases detected
# Install: Add to .claude/hooks.json under "user-prompt-submit" event

input=$(cat)

# Case-insensitive match for trigger phrases
if echo "$input" | grep -iqE '(write a spec|feature spec|nlspec|spec interview|dark factory spec|spec this step|spec this feature)'; then
  echo "Tip: This looks like a spec writing task. Use /feature-spec-interview for the structured NLSpec interview." >&2
fi

exit 0
