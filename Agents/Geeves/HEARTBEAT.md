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

## 5. Vault Tasks inbox → route new tasks

Check `/home/gunther/workspace/vault/Tasks/Inbox/` for `.md` files.

For each file found:

### 5a. Dead-letter check

Read the YAML frontmatter. Check the `routed_attempts` field (default 0 if absent).

**If `routed_attempts >= 3`:** dead-letter it:
1. Move the file to `/home/gunther/workspace/vault/Tasks/Dead Letter/`
2. Create a notification in `/home/gunther/workspace/agents/gunther/inbox/` named `YYYY-MM-DD-HH-MM-vault-dead-letter-<original-filename>`:
   ```
   # Dead-Letter Notice: <original filename>

   Task for: gunther

   ## Summary

   Geeves dead-lettered a vault task after 3 failed routing attempts.

   **File:** /home/gunther/workspace/vault/Tasks/Dead Letter/<original filename>
   **Time:** YYYY-MM-DD HH:MM MST

   ## Action Required

   - [ ] Review the dead-lettered task
   - [ ] Re-route manually to the correct agent, or discard
   ```
3. Skip to the next file.

**If `routed_attempts < 3`:** proceed to 5b.

### 5b. Normal routing

- Read the `task_for` field from YAML frontmatter.
- If `task_for` is missing or blank, route to Gunther.
- **If `kanban_tracked: true` in frontmatter:**
  - If `routed_attempts > 0`: **skip** (already routed; Stage 5c handles status sync going forward).
  - If `routed_attempts == 0`: **copy** the file to the destination agent's `inbox/` (do not move it); increment `routed_attempts` by 1 in the vault copy's frontmatter; leave the vault copy in `vault/Tasks/Inbox/`.
- **Otherwise (non-kanban file):** increment `routed_attempts` by 1 in the frontmatter; move the file to the destination agent's `inbox/`.
- Notify the destination agent via `sessions_send` (same as Stage 2b), fire-and-forget.

**Bridge mode:** Both this vault inbox pipeline and the legacy dropbox pipeline (Stage 4)
remain active until Paul explicitly confirms cutover ("Geeves, switch to vault-only routing").

## 5b. KANBAN.md Inbox section — convert inline tasks to routable files

Read `/home/gunther/workspace/vault/Tasks/KANBAN.md`.

Find the section between `## Inbox` and the next `## ` heading. Collect lines starting
with `- [ ]` that are NOT:
  - template placeholders (text: "Drop new tasks here")
  - note-backed links (format: `- [ ] [[...]]`)

These are real inline tasks that haven't been routed yet.

For each inline task found:

1. Extract the full text (the `- [ ]` line plus any indented continuation lines).
2. Guess the destination agent from the task text:
   - Mentions "charlie" (any case) → charlie
   - Mentions "reggie" (any case) → reggie
   - Mentions "plato" (any case) → plato
   - Mentions "devi" (any case) → devi
   - Otherwise → gunther
3. Create a task file in `vault/Tasks/Inbox/`:
   - Filename: `YYYY-MM-DD-HH-MM-<short-slug>.md` (slug = first 4-5 words, lowercase, hyphenated)
   - Frontmatter: `task_for`, `status: inbox`, `routed_attempts: 0`, `created: today`, `priority: normal`, `kanban_tracked: true`
   - Body: `## Original Task\n\n<full extracted text>`
4. In KANBAN.md, replace the inline entry block (the `- [ ]` line + any indented continuation
   lines) with a single linked-note card: `- [ ] [[<filename-without-.md>]]`. Keep it in the
   Inbox column. Do not remove the entry.
5. The new .md file will be picked up by Stage 5a/5b on the next heartbeat (or immediately
   if this stage runs before Stage 5 on this cycle — safe either way).

## 5c. KANBAN status sync — move cards to reflect agent folder state

Collect all kanban_tracked vault task files:
```bash
find /home/gunther/workspace/vault/Tasks -name "*.md" -type f
```

For each vault file with `kanban_tracked: true` in frontmatter:

1. Extract the bare filename (without `.md` extension) — this is the Obsidian link target.

2. Find the matching file in agent workspace folders:
   ```bash
   find /home/gunther/workspace/agents/*/inbox \
        /home/gunther/workspace/agents/*/inprogress \
        /home/gunther/workspace/agents/*/blocked \
        /home/gunther/workspace/agents/*/outbox \
        /home/gunther/workspace/agents/*/done \
        /home/gunther/workspace/dead-letter \
        -name "<filename>.md" -type f 2>/dev/null
   ```

3. Determine the target KANBAN column and vault subdir from agent folder:
   - `agent/inbox/`          → column "Inbox"        vault dir: `vault/Tasks/Inbox/`
   - `agent/inprogress/`     → column "In Progress"  vault dir: `vault/Tasks/In Progress/`
   - `agent/blocked/`        → column "Blocked"      vault dir: `vault/Tasks/Blocked/`
   - `agent/outbox/`         → column "Outbox"       vault dir: `vault/Tasks/Outbox/`
   - `agent/done/`           → column "Done"         vault dir: `vault/Tasks/Done/`
   - `workspace/dead-letter/`→ column "Dead Letter"  vault dir: `vault/Tasks/Dead Letter/`

4. If the vault file is already in the correct vault/Tasks/ subdir AND the KANBAN card
   is already in the correct column: no action needed.

5. If status changed:
   a. Move the vault `.md` file to the correct `vault/Tasks/` subdir.
   b. In KANBAN.md, find `- [ ] [[<filename>]]` (or `- [x] [[<filename>]]`) in any column,
      remove it, then insert in the target column:
      - Done or Dead Letter columns: use `- [x] [[<filename>]]`
      - All other columns: use `- [ ] [[<filename>]]`
   c. Leave all non-tracked entries (template placeholders) untouched.

6. If no matching agent file is found: the task may have been manually deleted or not yet
   routed. Leave vault file and KANBAN card in their current positions.

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
