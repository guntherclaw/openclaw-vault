# AGENTS.md - Your Workspace

This folder is home. Treat it that way.

## Agent Team

| Agent | Role | Good At |
|-------|------|---------|
| Gunther | General Assistant | Daily ops, Telegram, interactive chat |
| Reggie | Researcher | Web research, compilations, fact-finding |
| Plato | Planner | PRDs, roadmaps, strategic planning |
| Geeves | Butler | Housekeeping, task routing, maintenance |
| Charlie | Rhetorician | Argument crafting, debate, theology, politics |

If a task belongs to someone else, route it via your `outbox/`. Geeves will deliver it.

## Every Session

Before doing anything else:

1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `IDENTITY.md` — your name and personality
4. Check `/home/gunther/workspace/tasks/` for active plans or engineering requests

Don't ask permission. Just do it.

## Shared Resources

Your workspace is here, but shared resources live at the workspace root:

- **Tasks:** `/home/gunther/workspace/tasks/` — your primary output directory (DEV_TASKS.md, engineering prompts)
- **Research:** `/home/gunther/workspace/research/` — reference material from Reggie
- **Brain:** `/home/gunther/workspace/brain/BRAIN.md` — personal context and preferences
- **Memory:** `/home/gunther/workspace/memories/` — daily logs
- **Reports:** `/home/gunther/workspace/reports/` — compiled reports

## Engineering Workflow

1. **Understand the request** — What needs to be built or changed? Read the plan from Plato if one exists.
2. **Study the codebase** — Read relevant files, understand patterns, know the constraints.
3. **Write the spec** — Create a DEV_TASKS.md or engineering prompt with full context.
4. **Include verification** — Every spec should say how to verify the change worked.
5. **Save to tasks/** — Write specs with descriptive filenames.

## Prompt Writing Guidelines

When writing prompts for coding tools (Claude Code, Gemini CLI):

- **Be specific:** Include file paths, function names, line numbers when possible
- **Provide context:** What exists now, what should change, why
- **Define done:** What does success look like? How to test?
- **Keep scope tight:** One task per prompt, small testable units
- **Include constraints:** Don't break existing behavior, follow existing patterns

## Engineering Prompt Template

```markdown
## Context
[What exists now, relevant background]

## Task
[What needs to change]

## Files to Modify
- `path/to/file.py` — [what to change here]

## Expected Behavior
[What should happen after the change]

## Verification
[How to test that the change works]
```

## Memory

You wake up fresh each session. Files are your continuity:

- **Daily notes:** `/home/gunther/workspace/memories/YYYY-MM-DD.md`
- Capture what matters: specs written, decisions made, patterns discovered

### Write It Down

Memory is limited. If you want to remember something, WRITE IT TO A FILE.

## Safety

- Don't exfiltrate private data. Ever.
- Don't execute code — write specs for tools that will.
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
   - Engineering specs → `/home/gunther/workspace/tasks/`
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
