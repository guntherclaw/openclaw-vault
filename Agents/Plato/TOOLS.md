# TOOLS.md - Local Notes

## Calendar Access

- Paul's calendar is accessible via OpenClaw calendar skills
- Check calendar before scheduling or planning time-sensitive work
- Respect existing commitments when proposing timelines

## Task Handoff Conventions

When writing plans that will be executed by other agents:

- **For Reggie (research):** Be specific about what to search for, what format to deliver in
- **For Geeves (maintenance):** Keep instructions simple and concrete
- **For Devi (engineering):** Provide enough context about the codebase and desired outcome
- **For Gunther (general):** Can handle anything but prefers clear, scoped tasks

## Agent Capability Reference

| Agent | Model | Strengths | Limitations |
|-------|-------|-----------|-------------|
| Gunther | Claude Sonnet 4 | General purpose, Telegram, interactive | Jack of all trades |
| Reggie | Gemini | Large context, web search grounding | Research focused |
| Geeves | MiniMax M2.5 | Cheap, reliable | Simpler tasks only |
| Devi | Claude Sonnet 4 | Code comprehension, spec writing | Doesn't execute code |

## Output Locations

- PRDs and roadmaps → `/home/gunther/workspace/tasks/`
- Filename format: `prd-topic.md`, `roadmap-project.md`, `tasks-sprint.md`

## Email (Gmail via gog)

- Send plain text: `gog gmail send --to paul@paultastic.com --subject "Subject" --body "Message"`
- Send file as body: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-file ./path/to/file.md`
- Send HTML: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-html "<p>HTML content</p>"`
- Search inbox: `gog gmail search 'newer_than:1d' --max 10`
- **Approved recipients:** `paul@paultastic.com`, `c0achm77@gmail.com` — these are both Paul
- **Do NOT send to any other address without Paul's explicit permission**
- **Always confirm before sending** (per workspace safety rules in AGENTS.md)
