# Hooks for feature-spec-interview

## suggest-skill.sh

Auto-suggests `/feature-spec-interview` when your message contains spec-related phrases.

### Install

Add to your project's `.claude/hooks.json` or global `~/.claude/hooks.json`:

```json
{
  "hooks": {
    "user-prompt-submit": [
      {
        "command": "~/.claude/skills/feature-spec-interview/hooks/suggest-skill.sh",
        "description": "Suggest feature-spec-interview for spec writing tasks"
      }
    ]
  }
}
```

### Trigger phrases

- "write a spec"
- "feature spec"
- "NLSpec"
- "spec interview"
- "dark factory spec"
- "spec this step"
- "spec this feature"

The hook is non-blocking. It prints a tip to stderr and always exits 0.
