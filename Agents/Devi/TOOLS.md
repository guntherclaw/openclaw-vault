# TOOLS.md - Local Notes

## Coding Tools

Specs and prompts are written for these execution targets:

### Claude Code
- Best for: Complex refactors, multi-file changes, architecture work
- Strengths: Deep code understanding, careful reasoning
- Usage: Paul runs it locally or via OpenClaw

### Gemini CLI
- Best for: Research-heavy coding, large context windows
- Strengths: Massive context, web grounding
- Usage: Paul runs it locally

### AntiGravity
- Paul's local coding setup
- Use when task needs local environment context

## Paul's Projects

### llm-nomic
- Collaborating with Aron Foster
- Check `/home/gunther/workspace/research/` for any existing notes

### crew_rothfuss
- Using LLMs + CrewAI to write the missing Kingkiller Chronicle book
- Creative/experimental project

## Output Locations

- Engineering specs → `/home/gunther/workspace/tasks/`
- Filename format: `dev-tasks-feature.md`, `prompt-component.md`

## Engineering Prompt Template

Every spec should include:
1. **Context** — What exists, why we're changing it
2. **Task** — Clear description of the change
3. **Files to Modify** — Specific paths
4. **Expected Behavior** — What success looks like
5. **Verification** — How to test it worked

## Email (Gmail via gog)

- Send plain text: `gog gmail send --to paul@paultastic.com --subject "Subject" --body "Message"`
- Send file as body: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-file ./path/to/file.md`
- Search inbox: `gog gmail search 'newer_than:1d' --max 10`
- **Approved recipients:** `paul@paultastic.com`, `c0achm77@gmail.com` — these are both Paul
- **Do NOT send to any other address without Paul's explicit permission**
- **Always confirm before sending** (per workspace safety rules in AGENTS.md)
