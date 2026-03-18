# Claude Skills

100 shareable skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Built and maintained by the [AllCare](https://allcare.ai) team.

We use Claude Code across product, engineering, and design. These skills capture workflows we've battle-tested internally, plus community skills we've found useful.

## Install

One command. Installs all skills, configures hooks, done.

```bash
curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash
```

Install a single skill:

```bash
curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash -s -- feature-spec-interview
```

Other commands:

```bash
# Check for updates
curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash -s -- --check

# Uninstall
curl -fsSL https://raw.githubusercontent.com/AllCare-ai/claude-skills/main/install.sh | bash -s -- --uninstall
```

Restart Claude Code after installing. Type `/find-skills` to browse everything.

---

## Skills by Function

### 1. Product & Feature Specs

Everything a PM needs: spec writing, planning, strategy, research, and launch.

| Skill | Description |
|-------|-------------|
| `feature-spec-interview` | Interactive NLSpec interview. 5 modes, 40 question groups. Produces AI-agent-executable specs. |
| `brainstorming` | Structured creative exploration before building anything. |
| `writing-plans` | Create implementation plans from specs or requirements. |
| `executing-plans` | Execute plans with review checkpoints. |
| `doc-coauthoring` | Co-author documentation, proposals, technical specs, decision docs. |
| `internal-comms` | Status reports, leadership updates, newsletters, FAQs, incident reports. |
| `launch-strategy` | Product launch planning: phased launches, channel strategy, momentum. |
| `copywriting` | Marketing copy for homepage, landing, pricing, feature, product pages. |
| `copy-editing` | Systematic editing of marketing copy through multiple focused passes. |
| `social-content` | Social media content for LinkedIn, Twitter/X, Instagram, TikTok. |
| `email-sequence` | Drip campaigns, nurture sequences, onboarding emails, lifecycle programs. |
| `marketing-psychology` | 70+ mental models for marketing: cognitive biases, persuasion, decision-making. |
| `signup-flow-cro` | Optimize signup, registration, and trial activation flows. |
| `onboarding-cro` | Post-signup onboarding, activation, first-run experience, time-to-value. |
| `analytics-tracking` | GA4, GTM, conversion tracking, event tracking, UTM parameters. |
| `ralph-wiggum` | Devil's advocate reviewer. Finds logical gaps and questionable assumptions with humor. |

### 2. Coding

Code quality, review, testing, debugging, database, auth, and development workflows.

| Skill | Description |
|-------|-------------|
| **Quality & Clean Code** | |
| `solid` | SOLID principles, TDD, clean code for production-grade software. |
| `python-clean-code` | Full Clean Code catalog for Python: naming, functions, comments, DRY, boundaries. |
| `boy-scout` | Boy Scout Rule: always leave code cleaner than you found it. |
| `clean-names` | Descriptive names, appropriate length, no encodings. |
| `clean-functions` | Max 3 arguments, single responsibility, no flag parameters. |
| `clean-comments` | No metadata, no redundancy, no commented-out code. |
| `clean-tests` | Fast tests, boundary coverage, one assert per test. |
| `clean-general` | DRY, single responsibility, clear intent, no magic numbers. |
| `code-simplifier` | Simplify code for clarity and maintainability. Preserves functionality. |
| **Code Review** | |
| `code-review` | Structured code review for PRs and implementation phases. |
| `pr-review-toolkit` | Multi-agent PR review: code, silent failures, type design, test coverage. |
| `frontend-code-review` | Review frontend files (.tsx, .ts, .js) against checklist. |
| `requesting-code-review` | Verify requirements met before submitting for review. |
| `receiving-code-review` | Process review feedback with rigor, not blind implementation. |
| `verification-before-completion` | Run verification and confirm output before claiming done. |
| **Testing & Debugging** | |
| `test-driven-development` | TDD workflow. Use before writing implementation code. |
| `systematic-debugging` | Scientific debugging: hypotheses, investigation, root cause. |
| `webapp-testing` | Test local web apps with Playwright. Screenshots, browser logs. |
| **Database & Backend** | |
| `sql-optimization-patterns` | Query optimization, indexing, EXPLAIN analysis. |
| `supabase-postgres-best-practices` | Postgres performance optimization from Supabase. |
| `better-auth-best-practices` | Better Auth: comprehensive TypeScript authentication framework. |
| **DevOps & Git** | |
| `commit-commands` | Git commit, push, and PR creation workflows. |
| `using-git-worktrees` | Isolated worktrees for feature work with safety verification. |
| `finishing-a-development-branch` | Merge, PR, or cleanup when implementation is done. |
| `safe-file-deletion` | Enforces explicit permission before any file deletion. |
| `explain-code` | Explain code with visual diagrams and analogies. |

### 3. UI/UX & Design

Frontend interfaces, design systems, browser automation, diagrams, and visual art.

| Skill | Description |
|-------|-------------|
| **Frontend Design** | |
| `frontend-design` | Production-grade UI with high design quality. Avoids generic AI aesthetics. |
| `frontend-ui-ux-engineer-skill` | Designer-turned-developer. Stunning UI/UX without mockups. |
| `ui-ux-pro-max` | 50 styles, 21 palettes, 50 font pairings, 20 charts, 9 stacks. |
| `ui-ux-designer` | Interface design, interaction design, user experience, design systems. |
| `web-design-guidelines` | Review UI for Web Interface Guidelines compliance and accessibility. |
| `interface-craft` | Polished animated interfaces in React. Storyboard DSL, DialKit, Critique. |
| `vercel-react-best-practices` | React/Next.js performance optimization from Vercel Engineering. |
| **Components & Theming** | |
| `web-artifacts-builder` | Multi-component HTML artifacts with React, Tailwind, shadcn/ui. |
| `canvas-design` | Visual art in .png and .pdf. Posters, art, static designs. |
| `theme-factory` | 10 pre-set themes for slides, docs, reports, landing pages. |
| `brand-guidelines` | Anthropic's official brand colors and typography. |
| `motion` | Motion Vue animations: gesture, scroll-linked, layout transitions. |
| `remotion-best-practices` | Video creation in React with Remotion. |
| **Diagrams** | |
| `mermaid-diagrams` | Software diagrams: class, sequence, flowchart, ERD, C4, state, gantt. |
| `algorithmic-art` | Algorithmic art with p5.js: flow fields, particle systems. |
| **Browser Automation** | |
| `agent-browser` | Browser automation for testing, form filling, screenshots, extraction. |
| `dev-browser` | Persistent browser state. Navigate, fill, screenshot, scrape. |

### 4. AI & Agents

Build AI features, MCP servers, and multi-agent systems.

| Skill | Description |
|-------|-------------|
| `agent-sdk-dev` | Claude Agent SDK application development. |
| `mcp-builder` | Build MCP servers. Python (FastMCP) and Node/TypeScript. |
| `context7` | Retrieve up-to-date docs for any library via Context7 API. |
| `feature-dev` | Feature development workflow with agents. |
| `orchestrator` | Multi-agent orchestration. |
| `dispatching-parallel-agents` | Run 2+ independent tasks in parallel. |
| `subagent-driven-development` | Execute plans with independent subagent tasks. |
| `get-shit-done` | GSD meta-prompting: plan, execute, verify with context-rot prevention. |
| `para-memory-files` | PARA-method file-based memory: knowledge graph, daily notes, tacit knowledge, memory decay. |
| `agent-heartbeat-pattern` | Structured execution loop for agents that wake periodically. Checkout, incremental context, blocked-task dedup. |
| `agent-token-optimization` | Reduce token consumption in agent systems. Four root causes and systematic fixes from 11K+ production runs. |

### 5. Mobile & Native

iOS, macOS, and cross-platform mobile development.

| Skill | Description |
|-------|-------------|
| **Swift & iOS** | |
| `swift-expert` | iOS/macOS/watchOS/tvOS. SwiftUI, async/await, actors, protocols. |
| `ios-swift-development` | MVVM, SwiftUI, URLSession, Combine, Core Data. |
| `swift-style` | Swift code style: formatting, naming, organization. |
| `swift-testing-expert` | Swift Testing: #expect/#require, traits, parameterized tests, async. |
| `swift-protocol-di-testing` | Protocol-based DI for testable Swift. Mock file system, network, APIs. |
| `swift-mcp-server-generator` | Generate MCP server projects in Swift. |
| **SwiftUI** | |
| `swiftui-expert-skill` | State management, composition, performance, iOS 26+ Liquid Glass. |
| `swiftui-animation` | Animations, transitions, matched geometry, Metal shaders. |
| `swiftui-liquid-glass` | iOS 26+ Liquid Glass API. |
| `swiftui-performance-audit` | Diagnose slow rendering, janky scrolling, excessive updates. |
| `swiftui-pro` | Comprehensive SwiftUI review: modern APIs, maintainability, perf. |
| `swiftui-ui-patterns` | Example-driven guidance for views, components, TabView. |
| `rivetkit-client-swiftui` | RivetKit SwiftUI client: Rivet Actors, @Actor, view modifiers. |
| **Cross-Platform** | |
| `building-native-ui` | Expo Router: styling, components, navigation, animations, native tabs. |

### 6. Documents & Files

Create and manipulate office documents programmatically.

| Skill | Description |
|-------|-------------|
| `pdf` | Extract text/tables, create, merge/split, handle forms. |
| `docx` | Word docs: tracked changes, comments, formatting. |
| `pptx` | Presentations: layouts, speaker notes, content. |
| `xlsx` | Spreadsheets: formulas, formatting, data analysis, visualization. |
| `slack-gif-creator` | Animated GIFs optimized for Slack. |

### 7. Workflow & Meta

Skills that modify how Claude Code itself operates.

| Skill | Description |
|-------|-------------|
| `using-superpowers` | Skill discovery and invocation framework. |
| `find-skills` | Discover and install skills. "How do I do X?" |
| `skill-creator` | Create new skills or update existing ones. |
| `writing-skills` | Create, edit, and verify skills before deployment. |
| `hookify` | Create hooks to prevent unwanted behaviors. |
| `ask-user-question` | Ask users questions via UI for clarification. |
| `learning-output-style` | Learning mode with educational explanations. |
| `explanatory-output-style` | Educational insights about the codebase as you work. |
| `claude-opus-4-5-migration` | Migration utilities for Claude Opus 4.5. |
| `security-guidance` | Security hooks and guidance. |
| `file-permission` | File permission enforcement. |

---

## How Skills Work

Each skill is a folder under `skills/` with a `SKILL.md` file and optional `references/` directories. Claude Code reads the `SKILL.md` when invoked and loads reference files as needed.

Skills installed to `~/.claude/skills/` are globally available in every project.

Some skills are "plugins" with richer structure (commands/, agents/, hooks/). These provide slash commands, sub-agents, and automated hooks beyond the core skill.

## Contributing

We welcome contributions from the AllCare team and the community.

**Adding a new skill:**

1. Create a folder under `skills/` with your skill name
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`, `category`) and the skill instructions
3. Optionally add a `references/` directory for supporting files
4. Update `install.sh` if the skill needs hooks or special setup
5. Open a PR with a clear description of what the skill does and when to use it

**Improving an existing skill:**

- Fix unclear instructions, add missing edge cases, improve question flows
- Test by copying the updated `SKILL.md` to `~/.claude/skills/<skill-name>/` and running it

**Guidelines:**

- Skills should be self-contained. No external dependencies beyond Claude Code.
- Write instructions as if the reader has never seen the skill before.
- Include concrete examples where possible.
- Keep the scope focused. One skill, one job.

## Team

Built by [AllCare](https://allcare.ai). Maintained by the product and engineering teams.

## License

MIT
