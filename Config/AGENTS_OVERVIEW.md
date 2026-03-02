# Agent Team Overview

Human-readable reference for the OpenClaw agent roster.
For machine-readable config, see `~/.openclaw/openclaw.json`.

## Team

| Agent | Emoji | Model | Role |
|-------|-------|-------|------|
| Gunther | 🦊 | Gemini 3 Flash (+ Claude Sonnet 4 fallback) | General assistant, daily ops, personal memory |
| Plato | ♟️ | Gemini 3 Flash | Strategic planning, PRDs, structured thinking |
| Devi | ⚙️ | Claude Sonnet 4 | Engineering specs, architecture, code prompts |
| Reggie | 🔍 | Gemini 2.5 Pro | Research, web search, reports, news digest |
| Geeves | 🎩 | Gemini 2.5 Flash (+ Qwen3 32B fallback) | Butler, task routing, heartbeat every 10m |
| Charlie | ⚖️ | Claude Opus 4.6 | Rhetoric, debate, theology, politics |

## Heartbeats

- **Gunther**: 2h (morning briefing, memory consolidation)
- **Geeves**: 10m (task routing, backup trigger, dropbox scan)
- All others: on-demand (Telegram message or task file)

## Contact

All agents are reachable via Telegram. See individual `IDENTITY.md` files for bot handles.

## Identity Files

Each agent's identity, soul, and configuration lives in `vault/Agents/<Name>/`:

| File | Purpose |
|------|---------|
| `SOUL.md` | Identity, mission, core principles, output conventions |
| `IDENTITY.md` | Name, emoji, avatar, theme, Telegram handle |
| `AGENTS.md` | Workspace guide + agent team table + task system docs |
| `USER.md` | About Paul (same across all agents) |
| `TOOLS.md` | Tools available (web search, browse.sh, email, etc.) |
| `HEARTBEAT.md` | Boot prompt (heartbeat agents only) |

## Task Routing

Geeves is the task router. Drop a `.md` file into:
- `vault/Tasks/Inbox/` — with `task_for: <name>` frontmatter (vault pipeline, Phase 3+)
- `~/workspace/dropbox/` — with `Task for: <name>` header (legacy, Phase 1–2)

Geeves scans both locations on every 10-minute heartbeat.
