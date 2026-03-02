# Task File Format (Vault Edition)

All task files are markdown with YAML frontmatter. This format is used across all agents
once the vault task pipeline is live (Phase 3 cutover).

## Template

```markdown
---
task_for: <agent-name>
status: inbox
routed_attempts: 0
created: YYYY-MM-DD
priority: normal
---

# <Task Title>

## Original Task

<The original request, verbatim>

## Checklist

- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

## Blocked

n/a

## Answers

(filled in when blocking questions are answered)

## Notes

(working notes, findings, links)
```

## Frontmatter Fields

| Field | Values | Purpose |
|-------|--------|---------|
| `task_for` | agent name | Used by Geeves for routing |
| `status` | `inbox` / `inprogress` / `blocked` / `outbox` / `done` | Current pipeline stage |
| `routed_attempts` | integer | Incremented each failed route attempt; ≥3 → Dead Letter |
| `created` | YYYY-MM-DD | Creation date |
| `priority` | `low` / `normal` / `high` / `urgent` | Routing priority |

## Rules

- **`task_for`** is required. Geeves reads this for routing.
- **Title** should be descriptive. Agent may rename from the original filename.
- **Checklist** — agent adds steps during planning, checks them off as they go.
- **Blocked** — `n/a` means not blocked. When blocked, replace with checkbox questions,
  then move the file to `Tasks/Blocked/` and set `status: blocked`.
- **Answers** — filled in by Gunther (or Paul) when unblocking.
- **Notes** — agent's working space. Findings, links, intermediate results.

## Lifecycle

1. Task appears in `Tasks/Inbox/` (or is dropped into vault dropbox)
2. Geeves reads frontmatter, routes to correct agent's inbox
3. Agent moves file to `Tasks/In Progress/`, updates `status: inprogress`, adds checklist
4. If blocked → add questions, move to `Tasks/Blocked/`, set `status: blocked`
5. When unblocked → Paul adds answers, returns to `Tasks/Inbox/`
6. When done → deliverable saved to shared folder, file moved to `Tasks/Done/`
7. To hand off → update `task_for`, move to `Tasks/Outbox/`
8. Failed routing after 3 attempts → moved to `Tasks/Dead Letter/`

## Deliverable Naming

When a task is complete, save the deliverable to the appropriate shared folder:
- Research → `vault/Research/`
- Reports → `vault/Reports/`
- Notes → `vault/Notes/`
- Plans/specs → `vault/Config/` or `vault/Tasks/Done/`

Name: `YYYY-MM-DD-HH-MM-short-title.md`

Include the original task text near the top of every deliverable.

## Legacy Format Note

During Phase 2/3 transition, the old inline `Task for: <name>` header (no frontmatter)
is still supported for tasks in workspace agent inboxes. Once cutover is complete
(all agents confirmed routing from vault), all new tasks use frontmatter format.
