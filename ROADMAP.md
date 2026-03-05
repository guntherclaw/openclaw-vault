# OpenClaw → Obsidian Control Plane: Migration Roadmap

**Created:** 2026-03-01
**Status:** Phases 1–4 ✅ complete. Remaining: Phase 3 cutover from bridge mode to vault-only routing (say "Geeves, switch to vault-only routing" when ready).
**Vault root:** `~/workspace/vault/`
**Backup repo:** `openclaw-vault` (private GitHub ✅)

---

## Overview

This roadmap migrates the 6-agent OpenClaw setup from a pure filesystem/stow architecture
to an Obsidian-based control plane. The existing system stays live throughout. All changes
are additive and incremental; nothing is deleted until explicitly confirmed.

**Design decisions locked in:**
- Vault location: `~/workspace/vault/`
- Task pipeline: `vault/Tasks/` replaces workspace agent inboxes after Phase 3 cutover
- Backup: private GitHub repo `openclaw-vault` + existing rclone for runtime state
- Geeves primary model: `gemini/gemini-2.5-flash` (fallback: `ollama/qwen3:32b`)

---

## Current State (2026-03-05)

- [x] `~/workspace/vault/` directory created
- [x] Full folder skeleton in place (see structure below)
- [x] `Tasks/KANBAN.md` — obsidian-kanban board with all 6 columns
- [x] `Config/TASK_FORMAT.md` — adapted vault task format with frontmatter
- [x] `Config/AGENTS_OVERVIEW.md` — human-readable team summary
- [x] `Agents/<each>/` — all 6 agents' identity files synced from stow repo (2026-03-05)
- [x] `Brain/BRAIN.md` — populated from canonical `~/workspace/brain/BRAIN.md` (2026-03-05)
- [x] Obsidian installed and vault opened
- [x] Plugins installed: obsidian-kanban, templater, dataview, obsidian-git
- [x] obsidian-git configured (auto-commit + push every 10 min)
- [x] `openclaw-vault` private GitHub repo created and connected
- [x] `openclaw.json` `agentDir` paths updated to `vault/Agents/<Name>/`
- [x] Phase 3 HEARTBEAT changes: vault inbox routing + bidirectional KANBAN sync
- [x] Phase 4 backup: `backup-workspace.sh` includes vault git push

**Phase 2 remaining:**
- [ ] Verify each agent loads correctly (send test Telegram message to each)
- [ ] Remove stow-managed identity files (after verification)
- [ ] Commit stow repo cleanup

---

## Vault Folder Structure

```
vault/
├── .obsidian/
│   └── plugins/
│       ├── obsidian-kanban/
│       ├── templater-obsidian/
│       ├── dataview/
│       └── obsidian-git/
│
├── Agents/                      ← replaces stow-managed *.md identity files
│   ├── Gunther/
│   │   ├── SOUL.md
│   │   ├── IDENTITY.md
│   │   ├── AGENTS.md
│   │   ├── TOOLS.md
│   │   ├── USER.md
│   │   └── HEARTBEAT.md
│   ├── Geeves/   (same structure)
│   ├── Reggie/   (same structure)
│   ├── Plato/    (same structure)
│   ├── Devi/     (same structure)
│   └── Charlie/  (same structure)
│
├── Tasks/                       ← Kanban task board
│   ├── KANBAN.md                ← obsidian-kanban board
│   ├── Inbox/                   ← new/unassigned tasks
│   ├── In Progress/             ← agent has claimed it
│   ├── Blocked/                 ← waiting on Paul
│   ├── Outbox/                  ← ready for agent handoff
│   ├── Done/                    ← completed
│   └── Dead Letter/             ← routing failures (3+ attempts)
│
├── Brain/
│   └── BRAIN.md                 ← copy of ~/workspace/brain/BRAIN.md
│
├── Research/                    ← Reggie outputs
├── Reports/                     ← all agent reports
├── Notes/                       ← quick scratchpad
├── Memories/                    ← daily memory files (YYYY-MM-DD.md)
└── Config/
    ├── TASK_FORMAT.md           ← adapted task format with frontmatter
    └── AGENTS_OVERVIEW.md       ← human-readable team summary
```

---

## Phase 1 — Vault Infrastructure ✅ COMPLETE

**Goal:** Obsidian is running, vault is git-backed, KANBAN is live.

All steps complete as of 2026-03-05.

---

## Phase 2 — Agent Identity Migration ✅ COMPLETE

**Goal:** All agents load their identity files from `vault/Agents/<Name>/` instead of
the stow repo. The stow repo entries become redundant and are cleaned up.

### Steps

- [x] **Copy identity files into vault** — all 6 agents synced from stow repo (2026-03-05)
- [x] **`openclaw.json` updated** — all `agentDir` paths point to `vault/Agents/<Name>/`
- [x] **`Brain/BRAIN.md` populated** from canonical `~/workspace/brain/BRAIN.md`
- [x] **Verify each agent loads correctly** — all 6 agents confirmed responding via Telegram (2026-03-05)
- [x] **Remove old stow-managed identity files** — 36 files deleted from stow repo (2026-03-05)
- [x] **stow-sync.sh** — no changes needed; files absent from stow package are not tracked

> **Note:** Going forward, agent identity files live in `vault/Agents/<Name>/` and are
> managed there directly. obsidian-git auto-commits and pushes changes. The stow repo
> is no longer the source of truth for agent *.md files.

---

## Phase 3 — Task Routing Logic (Kanban Watcher) ✅ COMPLETE

**Goal:** Geeves routes tasks from `vault/Tasks/Inbox/` in addition to (then instead of)
the legacy workspace agent inboxes.

All HEARTBEAT.md changes implemented as of 2026-03-05:
- Stage 5: vault inbox routing with frontmatter `task_for` field
- Stage 5b: KANBAN inline card → linked-note card conversion (`kanban_tracked: true`)
- Stage 5c: bidirectional KANBAN sync (agent folder state → KANBAN columns)
- Bridge mode: both vault and legacy dropbox pipelines active

**Cutover** (when ready — say "Geeves, switch to vault-only routing"):
1. Archive legacy inboxes: `cp -r ~/workspace/agents/*/inbox ~/workspace/agents/*/inbox.archive`
2. Remove legacy task folders from workspace (after 1-week confirmation period)

---

## Phase 4 — Automated Backups ✅ COMPLETE

**Goal:** Vault is automatically backed up to GitHub; runtime workspace state backed up
via rclone as before.

All components in place as of 2026-03-05:
- obsidian-git: auto-commit + push every 10 min
- `backup-workspace.sh`: vault git push runs before rclone sync
- rclone: continues backing up runtime workspace state

**Recovery procedure:**
- Vault: `git clone git@github.com:<user>/openclaw-vault ~/workspace/vault`
- Runtime: restore from rclone Google Drive remote `gunther-openclaw-workspace`
- OpenClaw config: re-stow from `~/projects/openclaw-config`

---

## `openclaw.json` Changes ✅ APPLIED

All `agentDir` paths updated to `vault/Agents/<Name>/`. Geeves model updated to
`gemini/gemini-2.5-flash` with `ollama/qwen3:32b` fallback.

---

## Rollback Plan

Since this migration is additive:
- **Rollback Phase 1**: delete `~/workspace/vault/` — no other system is affected
- **Rollback Phase 2**: revert `agentDir` in `openclaw.json` to `.openclaw/agents/<id>/agent`, restow, restart
- **Rollback Phase 3**: revert Geeves HEARTBEAT.md to legacy-only scan, restow
- **Rollback Phase 4**: remove vault git push lines from backup-workspace.sh

No data is lost at any rollback point during Phases 1–3 (files are copied, not moved).
