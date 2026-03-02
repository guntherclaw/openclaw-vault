# HEARTBEAT.md - Geeves Task Routing

Every heartbeat, run through this checklist in order.

## 1. Blocked tasks → route to Gunther

Run:
```bash
find /home/gunther/workspace/agents/*/blocked -name "*.md" -type f 2>/dev/null
```
This covers all agents automatically, including any future additions.

If you find a file, move it to `/home/gunther/workspace/agents/gunther/inbox/`.

## 2. Outbox tasks → route to target agent

Run:
```bash
find /home/gunther/workspace/agents/*/outbox -name "*.md" -type f 2>/dev/null
```

For each task file found:

### 2a. Dead-letter check (do this first)

Look for a `## Geeves Routing Log` section in the file. Count the bullet entries (lines starting with `- `).

**If there are 3 or more entries:** this task is looping. Dead-letter it:
1. Append to the routing log:
   `- YYYY-MM-DD HH:MM MST | DEAD-LETTER | would be attempt 4 — moved to /home/gunther/workspace/dead-letter/ for manual review`
2. Append at the bottom of the file:
   ```
   ## Dead-Letter Notice

   Moved to dead-letter by Geeves on YYYY-MM-DD HH:MM MST.
   Routed 3 times without completing. Manual review required.
   Last routing: outbox:<current agent> — intended for <Task for: value>
   ```
3. Move the file to `/home/gunther/workspace/dead-letter/` (run `mkdir -p /home/gunther/workspace/dead-letter/` first if the directory doesn't exist).
4. Create a notification in `/home/gunther/workspace/agents/gunther/inbox/` named `YYYY-MM-DD-HH-MM-dead-letter-<original-filename>`:
   ```
   # Dead-Letter Notice: <original filename>

   Task for: gunther

   ## Summary

   Geeves dead-lettered a task that was routed 3 times without completing.

   **File:** /home/gunther/workspace/dead-letter/<original filename>
   **Time:** YYYY-MM-DD HH:MM MST

   ## Action Required

   - [ ] Review the dead-lettered task
   - [ ] Re-route manually to the correct agent, or discard
   ```
5. Skip to the next task. Do not route this one.

**If there are 0, 1, or 2 entries (or no log section):** proceed to 2b.

### 2b. Normal routing

- Read the `Task for: <agent-name>` line.
- If there is no `## Geeves Routing Log` section at the bottom of the file, add one.
- Append a log entry:
  `- YYYY-MM-DD HH:MM MST | outbox:<current agent> → inbox:<destination agent> | attempt <N>`
  (N = total entries in the log after appending this one)
- Move the file to the destination agent's `inbox/`.
- Notify the destination agent:
  1. Run `sessions_list` and find the session whose key or label contains the agent name.
  2. Use `sessions_send` with the `sessionKey`. Message: `"New task in your inbox: [task filename]"`. Use `timeoutSeconds: 0` (fire-and-forget).
  3. If no active session is found, skip the notification.

## 3. Email inbox → route new tasks

Check Gmail for recent unread emails from Paul:

```bash
gog gmail messages search 'is:unread (from:c0achm77@gmail.com OR from:paul@paultastic.com OR from:poliver@google.com)' --max 10
```

For each matching email:
1. Read the full email content: `gog gmail get <messageId>`
2. Create a task file in `/home/gunther/workspace/dropbox/` using the standard task format:
   - Title: use the email subject line
   - `Task for:` — classify like dropbox routing (research → reggie, planning → plato, code specs → devi, unclear → gunther)
   - `## Original Task` — the email body text
   - Filename: `YYYY-MM-DD-HH-MM-email-short-subject.md`
3. Mark the email as read so it isn't picked up again: `gog gmail thread modify <threadId> --remove UNREAD`
4. The dropbox stage (Stage 4) will handle actual routing on this same heartbeat cycle

**Only process emails from these senders:**
- `c0achm77@gmail.com`
- `paul@paultastic.com`
- `poliver@google.com`

Ignore all other senders — do not create tasks from them.

## 4. Dropbox → route new tasks

Check `/home/gunther/workspace/dropbox/` for `.md` files.
- If the file has `Task for: <name>`, route to that agent's `inbox/`
- Otherwise, read and decide:
  - Research/facts/lookups → reggie
  - Planning/roadmaps/strategy → plato
  - Code specs/engineering prompts → devi
  - Everything else or unclear → gunther
- If unsure, move to Gunther's inbox with `## Blocked` section: `- [ ] Who is this task for?`

Before moving the file:
- If there is no `## Geeves Routing Log` section, add one at the bottom of the file.
- Append the first log entry:
  `- YYYY-MM-DD HH:MM MST | dropbox → inbox:<destination agent> | attempt 1`
Then move the file to the destination agent's `inbox/`.

## 5. Vault inbox → route to agent inboxes (bridge mode)

Check `/home/gunther/workspace/vault/Tasks/Inbox/` for `.md` files.

For each file found:

### 5a. Dead-letter check

Read the `routed_attempts` field from the YAML frontmatter (between the `---` delimiters at the top of the file). If `routed_attempts` is 3 or more:

1. Move the file to `/home/gunther/workspace/vault/Tasks/Dead Letter/` (create with `mkdir -p` if needed).
2. Create a notification in `/home/gunther/workspace/agents/gunther/inbox/` named `YYYY-MM-DD-HH-MM-dead-letter-<original-filename>`:
   ```
   # Dead-Letter Notice: <original filename>

   Task for: gunther

   ## Summary

   Geeves dead-lettered a vault task after 3 failed routing attempts.

   **File:** /home/gunther/workspace/vault/Tasks/Dead Letter/<original filename>
   **Time:** YYYY-MM-DD HH:MM MST

   ## Action Required

   - [ ] Review the dead-lettered task
   - [ ] Re-route manually or discard
   ```
3. Skip to the next file — do not route this one.

### 5b. Normal routing

1. Read the `task_for` field from YAML frontmatter.

2. Map to destination agent inbox:
   - `gunther` → `/home/gunther/workspace/agents/gunther/inbox/`
   - `plato` → `/home/gunther/workspace/agents/plato/inbox/`
   - `devi` → `/home/gunther/workspace/agents/devi/inbox/`
   - `reggie` → `/home/gunther/workspace/agents/reggie/inbox/`
   - `geeves` → `/home/gunther/workspace/agents/geeves/inbox/`
   - `charlie` → `/home/gunther/workspace/agents/charlie/inbox/`

3. If `task_for` is missing or unrecognized: route to Gunther's inbox and append a `## Blocked` section to the file: `- [ ] Unrecognized task_for value — route manually`.

4. Increment `routed_attempts` in the frontmatter (add it as `routed_attempts: 1` if not present).

5. Move the file to the destination agent's `inbox/`.

6. Notify the destination agent (same method as Stage 2b):
   - Run `sessions_list`, find the session matching the agent name.
   - Use `sessions_send` with the session key. Message: `"New task in your inbox: [task filename]"`. Use `timeoutSeconds: 0`.
   - If no active session, skip.

**Bridge mode note:** Both vault inbox (this stage) and legacy dropbox/email pipelines remain active. Vault-sourced tasks are moved to legacy agent inboxes during this transition period.

## 6. Inbox notifications

Run:
```bash
find /home/gunther/workspace/agents/*/inbox -name "*.md" -type f ! -path "*/gunther/*" 2>/dev/null
```

For each file found, notify the agent:
1. Run `sessions_list` and find the session whose key or label contains the agent name
2. Use `sessions_send` with the `sessionKey` from that result. Message: `"Task waiting in your inbox: [task filename]"`. Use `timeoutSeconds: 0` (fire-and-forget).
3. If no active session is found, skip the notification (the agent isn't online).

(Gunther's inbox is skipped — Gunther is not a session agent.)

## 7. Stuck task detection

For each check below, run the command then act on each result as described.

**Stale inbox files (sitting unread for 2+ hours):**
```bash
find /home/gunther/workspace/agents/*/inbox -name "*.md" -type f -mmin +120 ! -path "*/gunther/*" 2>/dev/null
```
For each file: append `> Escalated by Geeves: this task has been sitting in {agent}'s inbox for {time}.` then move to `/home/gunther/workspace/agents/gunther/inbox/`.

**Stuck inprogress files (not modified in 4+ hours):**
```bash
find /home/gunther/workspace/agents/*/inprogress -name "*.md" -type f -mmin +240 2>/dev/null
```
For each file: append `> Escalated by Geeves: this task appears stuck in {agent}'s inprogress for {time}.` then move to `/home/gunther/workspace/agents/gunther/inbox/`.

**Unrouted blocked files** are handled by Stage 1.

## 8. Done/ cleanup (low priority)

Run:
```bash
find /home/gunther/workspace/agents/*/done -name "*.md" -type f -mtime +30 2>/dev/null
```
For each file listed, delete it with `rm`.

## 9. Workspace backup (conditional)

Run `bash /home/gunther/workspace/scripts/backup-workspace.sh --force` if the last backup was more than 4 hours ago.

To check: look at the last modified time of `/home/gunther/workspace/scripts/backup-workspace.sh`'s output, or check the timestamp file at `/tmp/openclaw-last-backup`. If the file doesn't exist or is older than 4 hours, run the backup. After a successful backup, update the timestamp: `date +%s > /tmp/openclaw-last-backup`.

If you ran the backup, report the result. If skipped (too recent), no need to mention it.

## Reporting

- If you took any actions, report them clearly.
- If nothing needed attention, reply `HEARTBEAT_OK`.
