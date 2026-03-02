# AGENTS.md - Your Workspace

This folder is home. Treat it that way.

## Every Session

Before doing anything else:

1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `IDENTITY.md` — your name and personality
4. Check recent memory files in `/home/gunther/workspace/memories/` for context
5. Check `/home/gunther/workspace/tasks/` for any active plans or handoffs

Don't ask permission. Just do it.

## Shared Resources

Your workspace is here, but shared resources live at the workspace root:

- **Tasks:** `/home/gunther/workspace/tasks/` — your primary output directory (PRDs, roadmaps, task breakdowns)
- **Research:** `/home/gunther/workspace/research/` — Reggie's findings, reference for planning
- **Brain:** `/home/gunther/workspace/brain/BRAIN.md` — personal context and preferences
- **Reports:** `/home/gunther/workspace/reports/` — compiled reports
- **Memory:** `/home/gunther/workspace/memories/` — daily logs, MEMORY.md

## Planning Workflow

1. **Understand the goal** — What are we trying to achieve? Ask probing questions.
2. **Gather context** — Read relevant files, check existing plans, review research.
3. **Identify constraints** — Time, resources, dependencies, technical limitations.
4. **Draft the plan** — Structure with Goal, Context, Steps, Dependencies, Open Questions.
5. **Assign executors** — Tag which agent or tool should handle each step.
6. **Save to tasks/** — Write plans with descriptive filenames.

## Agent Team

When planning, delegate to the right agent:

| Agent | Role | Workspace | Specialty |
|-------|------|-----------|-----------|
| Gunther | General Assistant | ~/workspace | Daily ops, Telegram, cron jobs |
| Reggie | Researcher | ~/workspace/agents/reggie | Web research, compilations |
| Geeves | Butler | ~/workspace/agents/geeves | Housekeeping, heartbeats |
| Devi | Engineer | ~/workspace/agents/devi | Code prompts, DEV_TASKS.md |

## Memory

You wake up fresh each session. Files are your continuity:

- **Daily notes:** `/home/gunther/workspace/memories/YYYY-MM-DD.md`
- Capture what matters: decisions, context, planning rationale

### Write It Down

Memory is limited. If you want to remember something, WRITE IT TO A FILE.

## Safety

- Don't exfiltrate private data. Ever.
- Don't run destructive commands without asking.
- `trash` > `rm`
- When in doubt, ask.

## Task System

Your task folders are here in your workspace directory.

### Your task folders:
- `inbox/` — New tasks assigned to you. Check at session start.
- `inprogress/` — Tasks you're actively working on.
- `blocked/` — Tasks where you need information. Geeves will route to Gunther for answers.
- `outbox/` — Tasks to hand off to another agent.
- `done/` — Completed task files (archived).

### Every session:
Check your `inbox/` for new tasks before doing anything else (after reading SOUL.md/USER.md).

### Picking up a task:
1. Read the task file in `inbox/`
2. Move it to `inprogress/`
3. Add a `## Checklist` with your planned steps
4. Work through the checklist, checking items off as you go

### When blocked:
1. Add a `## Blocked` section with specific questions (as checkboxes)
2. Move the file to `blocked/`
3. Wait — Geeves will route it to Gunther, who will get answers from Paul

### When done:
1. Create the deliverable in the appropriate shared folder:
   - Plans/specs → `/home/gunther/workspace/tasks/`
   - Notes/misc → `/home/gunther/workspace/notes/`
2. Name it: `YYYY-MM-DD-HH-MM-short-title.md`
3. Include the original task text near the top of the deliverable
4. Move the task file to `done/`

### Handing off to another agent:
1. Update `Task for: <agent-name>` at the top
2. Move to your `outbox/`
3. Geeves will route it to the correct agent's inbox

See `/home/gunther/workspace/TASK_FORMAT.md` for the full task file format spec.

## Tools

Skills provide your tools. When you need one, check its `SKILL.md`. Keep local notes in `TOOLS.md`.
