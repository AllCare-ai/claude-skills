# Claude Skills

Shareable skills for Claude Code. Built by Ramy Barsoum.

## Install

One command. Installs the skill, configures hooks, done.

```bash
curl -fsSL https://raw.githubusercontent.com/ramybarsoum/claude-skills/main/install.sh | bash
```

That's it. Restart Claude Code and type `/feature-spec-interview`.

**What the installer does:**
1. Downloads skill files to `~/.claude/skills/`
2. Registers the suggestion hook in `~/.claude/hooks.json` (auto-suggests the skill when you say "write a spec")
3. Makes hook scripts executable

**Other commands:**

```bash
# Check for updates
curl -fsSL https://raw.githubusercontent.com/ramybarsoum/claude-skills/main/install.sh | bash -s -- --check

# Uninstall (removes skill + hook)
curl -fsSL https://raw.githubusercontent.com/ramybarsoum/claude-skills/main/install.sh | bash -s -- --uninstall
```

## Available Skills

### feature-spec-interview

Interactive interview that produces AI-agent-executable feature specifications (NLSpec). Based on the Dark Factory Framework.

**Invoke:** `/feature-spec-interview`

**What it does:** Interviews you (PM, engineer, or both) to produce specs precise enough that an AI agent or capable new hire could implement with at most one clarifying question. Every behavior gets four components: WHAT, WHEN, WHY, VERIFY.

**5 interview modes:**

| Mode | Who it's for | What happens |
|------|-------------|--------------|
| **All** | Solo (PM + Eng) | Ask all 40 question groups. Full spec. |
| **PM-first** | Product Manager | Ask PM + shared questions. Eng questions become `[OPEN - Engineering]`. |
| **Eng-first** | Engineer | Ask Eng + shared questions. PM questions become `[OPEN - PM]`. |
| **Fill-gaps** | Anyone | Load existing spec, answer only the `[OPEN]` items. |
| **Quick** | Anyone, simple steps | Core behavioral + security/data lifecycle only (12 groups instead of 40). |

**40 question groups across 10 prompts:**

| Prompt | Groups | Coverage |
|--------|--------|----------|
| 1-3 (Behavioral) | 1-12 | Output, constraints, edge cases, tradeoffs, delegation, failure modes |
| 5-9 (Production Bridge) | 13-30 | NFRs, scenarios, testing, data contracts, observability |
| 10 (MECE Gaps) | 31-40 | Security, data lifecycle, rollout, incident response, ops readiness |

**Team workflow:**

1. PM runs in **PM-first** mode, produces spec with `[OPEN - Engineering]` placeholders
2. Engineer runs in **Fill-gaps** mode on the same spec, answers the engineering questions
3. Both sides review the complete spec

Or one person runs **All** mode and handles everything.

**Shared project context:** On first run, the skill asks intake questions (elevator pitch, executor type, scope). Answers are saved to `.spec-project-context.md` in the project root. Subsequent team members skip intake and load from this file.

## How Skills Work

Each skill is a folder with a `SKILL.md` file and optional `references/` directories. Claude Code reads the `SKILL.md` when the skill is invoked and loads reference files as needed.

Skills at `~/.claude/skills/` are globally available in every project.

## License

MIT
