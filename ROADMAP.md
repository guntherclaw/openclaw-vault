# OpenClaw → Obsidian Control Plane: Migration Roadmap

**Created:** 2026-03-01
**Status:** Phases 1–4 complete (automated steps). Pending: Obsidian install + plugin setup (manual), agent verification (Phase 2 step 3), Phase 2 stow cleanup.
**Vault root:** `~/workspace/vault/`
**Backup repo:** `openclaw-vault` (private GitHub, to be created)

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

## Current State (post Phase 1 bootstrap)

The vault skeleton has been created by Claude Code. The following are **done**:

- [x] `~/workspace/vault/` directory created
- [x] Full folder skeleton in place (see structure below)
- [x] `Tasks/KANBAN.md` — obsidian-kanban board with all 6 columns
- [x] `Config/TASK_FORMAT.md` — adapted vault task format with frontmatter
- [x] `Config/AGENTS_OVERVIEW.md` — human-readable team summary
- [x] `Agents/<each>/` placeholder files (6 agents × 6 files)
- [x] `Brain/BRAIN.md` — placeholder pointing to canonical source

**Still to do in Phase 1:**
- [ ] Install Obsidian on your machine
- [ ] Open vault at `~/workspace/vault/` in Obsidian
- [ ] Install plugins: obsidian-kanban, templater, dataview, obsidian-git
- [ ] Configure obsidian-git: auto-commit every 10 min, push to `openclaw-vault` repo
- [ ] Create `openclaw-vault` private GitHub repo and push initial commit
- [ ] Review and apply `openclaw.json` diff (see below)

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

## Phase 1 — Vault Infrastructure

**Goal:** Obsidian is running, vault is git-backed, KANBAN is live.

### Steps

1. **Install Obsidian**
   - Download from https://obsidian.md and install on your machine
   - Open vault: File → Open folder as vault → `~/workspace/vault/`

2. **Install plugins** (Settings → Community plugins → Browse)
   - `obsidian-kanban` — Kanban board support
   - `templater-obsidian` — File templates
   - `dataview` — SQL-like queries across notes
   - `obsidian-git` — Git integration for auto-backup

3. **Configure obsidian-git**
   - Auto pull interval: 10 minutes
   - Auto commit + push interval: 10 minutes
   - Commit message: `vault: auto-backup {{date}}`
   - Push on auto-commit: enabled

4. **Create GitHub repo and push**
   ```bash
   cd ~/workspace/vault
   git init
   git add -A
   git commit -m "feat: initial vault skeleton"
   gh repo create openclaw-vault --private --source=. --push
   ```

5. **Review and apply `openclaw.json` diff** (see below)

6. **Restow after config change**
   ```bash
   cd ~/projects/openclaw-config
   stow --ignore='jobs\.json' -t /home/gunther home
   ```

7. **Restart OpenClaw** to pick up new `agentDir` paths and Geeves model change.

---

## Phase 2 — Agent Identity Migration

**Goal:** All agents load their identity files from `vault/Agents/<Name>/` instead of
the stow repo. The stow repo entries become redundant and are cleaned up.

**Principle:** Copy first, verify, then remove old files.

### Steps

1. **Copy identity files into vault** (for each agent):
   ```bash
   for agent in gunther geeves reggie plato devi charlie; do
     NAME=$(python3 -c "print('$agent'.capitalize())")
     cp ~/projects/openclaw-config/home/workspace/agents/$agent/*.md \
        ~/workspace/vault/Agents/$NAME/
   done
   # Gunther's files live at workspace root, not agents/gunther/
   cp ~/projects/openclaw-config/home/workspace/{SOUL,IDENTITY,AGENTS,TOOLS,USER,HEARTBEAT}.md \
      ~/workspace/vault/Agents/Gunther/
   ```

2. **`openclaw.json` is already updated** (after Phase 1 diff application) — each agent's
   `agentDir` now points to `vault/Agents/<Name>/`.

3. **Verify each agent loads correctly**
   - Restart OpenClaw
   - Send each agent a test message via Telegram; confirm they respond with correct identity
   - Check OpenClaw logs: `~/.openclaw/logs/` for any "file not found" errors on SOUL.md

4. **Remove old stow-managed identity files** (after successful verification):
   ```bash
   # Remove from stow repo (they now live in vault)
   rm ~/projects/openclaw-config/home/workspace/agents/geeves/*.md
   # ... repeat for each agent
   rm ~/projects/openclaw-config/home/workspace/{SOUL,IDENTITY,AGENTS,TOOLS,USER,HEARTBEAT}.md
   cd ~/projects/openclaw-config && git add -A && git commit -m "chore: remove agent identity files (moved to vault)"
   ```

5. **Update stow-sync.sh ignore list** if needed to skip vault-managed paths.

---

## Phase 3 — Task Routing Logic (Kanban Watcher)

**Goal:** Geeves routes tasks from `vault/Tasks/Inbox/` in addition to (then instead of)
the legacy workspace agent inboxes.

### Geeves HEARTBEAT.md changes

Update `~/workspace/agents/geeves/HEARTBEAT.md` (via stow repo) to:

1. **Scan vault inbox** alongside legacy inboxes:
   ```
   Scan locations:
   - vault: ~/workspace/vault/Tasks/Inbox/       ← NEW (frontmatter routing)
   - legacy: ~/workspace/agents/*/inbox/         ← KEEP during bridge period
   ```

2. **Route vault tasks using frontmatter** instead of inline `Task for:` header:
   ```
   vault routing: read YAML frontmatter field `task_for` to determine destination
   legacy routing: read first `Task for: <name>` line (unchanged)
   ```

3. **Dead-letter logic** (vault tasks only):
   ```
   if routed_attempts >= 3:
     move to vault/Tasks/Dead Letter/
     notify Gunther via Telegram
   else:
     increment routed_attempts in frontmatter
     retry next heartbeat
   ```

4. **Escalation timers** (unchanged from legacy):
   - 2h in Inbox without pickup → notify Paul
   - 4h in In Progress without update → notify Paul

5. **Bridge mode**: both pipelines active until all agents confirm vault routing works.
   Cutover gate: Paul manually confirms ("Geeves, switch to vault-only routing").

### Geeves model change (already in Phase 1 `openclaw.json` diff)

- Primary: `gemini/gemini-2.5-flash`
- Fallback: `ollama/qwen3:32b`

### Cutover

Once all agents are confirmed routing from vault:
1. Archive legacy inboxes: `cp -r ~/workspace/agents/*/inbox ~/workspace/agents/*/inbox.archive`
2. Remove legacy task folders from workspace (after 1-week confirmation period)

---

## Phase 4 — Automated Backups

**Goal:** Vault is automatically backed up to GitHub; runtime workspace state backed up
via rclone as before.

### Components

1. **Obsidian Git** (configured in Phase 1): auto-commit + push to `openclaw-vault` every 10 min.
   This is the primary vault backup mechanism.

2. **backup-workspace.sh update**: add vault git push before rclone step:
   ```bash
   # Add near top of ~/workspace/scripts/backup-workspace.sh:
   echo "Pushing vault to GitHub..."
   git -C ~/workspace/vault add -A
   git -C ~/workspace/vault commit -am "auto-backup $(date -u +%Y-%m-%dT%H:%M:%SZ)" || true
   git -C ~/workspace/vault push || echo "WARNING: vault push failed"
   ```

3. **Geeves backup stage**: update HEARTBEAT.md to run vault git push *before* rclone sync
   (so vault is never stale when rclone captures runtime state).

4. **rclone**: continues to backup `~/workspace/` runtime state (inboxes, sessions, logs).
   Vault is excluded from rclone since it has its own git-based backup.

5. **Recovery procedure**: document in `vault/Config/BACKUP_RECOVERY.md`:
   - Vault: `git clone git@github.com:<user>/openclaw-vault ~/workspace/vault`
   - Runtime: restore from rclone Google Drive remote `gunther-openclaw-workspace`
   - OpenClaw config: re-stow from `~/projects/openclaw-config`

---

## `openclaw.json` Diff (review before applying)

> **Do not apply automatically.** Review this diff, then edit the stow-managed config at:
> `~/projects/openclaw-config/home/.openclaw/openclaw.json`
>
> After editing, restow and restart OpenClaw.

### agentDir changes (one per agent in `agents.list`)

```jsonc
// main / Gunther  — currently: /home/gunther/.openclaw/agents/main/agent
"agentDir": "/home/gunther/workspace/vault/Agents/Gunther",

// geeves  — currently: /home/gunther/.openclaw/agents/geeves/agent
"agentDir": "/home/gunther/workspace/vault/Agents/Geeves",

// plato  — currently: /home/gunther/.openclaw/agents/plato/agent
"agentDir": "/home/gunther/workspace/vault/Agents/Plato",

// devi  — currently: /home/gunther/.openclaw/agents/devi/agent
"agentDir": "/home/gunther/workspace/vault/Agents/Devi",

// reggie  — currently: /home/gunther/.openclaw/agents/reggie/agent
"agentDir": "/home/gunther/workspace/vault/Agents/Reggie",

// charlie  — currently: /home/gunther/.openclaw/agents/charlie/agent
"agentDir": "/home/gunther/workspace/vault/Agents/Charlie",
```

### Geeves model change

Current:
```json
{
  "id": "geeves",
  "model": {
    "primary": "ollama/qwen3:32b",
    "fallbacks": [
      "ollama/qwen3:32b",
      "gemini/gemini-2.5-flash",
      "minimax-portal/MiniMax-M2.5"
    ]
  }
}
```

After:
```json
{
  "id": "geeves",
  "model": {
    "primary": "gemini/gemini-2.5-flash",
    "fallbacks": [
      "ollama/qwen3:32b"
    ]
  }
}
```

Note: `gemini-2.5-flash` is already defined in `models.providers.gemini` with
`"compat": { "supportsStore": false }` — no new model entry needed.

### New top-level `vault` section (add after `"gateway"` block)

```json
"vault": {
  "root": "/home/gunther/workspace/vault",
  "taskBoard": "/home/gunther/workspace/vault/Tasks",
  "kanbanFile": "/home/gunther/workspace/vault/Tasks/KANBAN.md"
}
```

Note: Check whether the current OpenClaw version reads this section. If not, it's a
no-op comment for documentation purposes — safe to add regardless.

---

## Verification Checklist

After Phase 1 is complete:

```bash
# 1. Confirm folder skeleton
ls ~/workspace/vault/

# 2. Confirm KANBAN columns
cat ~/workspace/vault/Tasks/KANBAN.md

# 3. Confirm agent placeholders
ls ~/workspace/vault/Agents/

# 4. Confirm ROADMAP is present
ls ~/workspace/vault/ROADMAP.md

# 5. Confirm git is initialised (after you run git init)
git -C ~/workspace/vault status
```

---

## Rollback Plan

Since this migration is additive:
- **Rollback Phase 1**: delete `~/workspace/vault/` — no other system is affected
- **Rollback Phase 2**: revert `agentDir` in `openclaw.json` to `.openclaw/agents/<id>/agent`, restow, restart
- **Rollback Phase 3**: revert Geeves HEARTBEAT.md to legacy-only scan, restow
- **Rollback Phase 4**: remove vault git push lines from backup-workspace.sh

No data is lost at any rollback point during Phases 1–3 (files are copied, not moved).
