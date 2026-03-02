# TOOLS.md - Local Notes

## Backup Script

- **Location:** `/home/gunther/workspace/scripts/backup-workspace.sh`
- **Remote:** Google Drive via rclone (`gunther-openclaw-workspace`)
- **Flags:** `--force` for non-interactive, `--dry-run` to preview
- **Schedule:** 9am and 9pm MST via OpenClaw cron

## Health Checks

### Git Status
```bash
cd /home/gunther/workspace && git status --short
```

### Disk Usage
```bash
df -h /home/gunther
```

### Ollama Server
```bash
curl -s http://trogdor.lan:11434/api/tags | jq '.models | length'
```
Expected: 8+ models available on trogdor.lan

### Stale Tasks
Check `/home/gunther/workspace/tasks/` for files with mtime > 7 days.

## Infrastructure Notes

- **Ollama server:** trogdor.lan:11434 (remote NVIDIA box)
- **Workspace size limit:** 12GB total
- **No files over 100MB** (media is gitignored)

## Email (Gmail via gog)

- Send plain text: `gog gmail send --to paul@paultastic.com --subject "Subject" --body "Message"`
- Send file as body: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-file ./path/to/file.md`
- Search inbox: `gog gmail search 'newer_than:1d' --max 10`
- Search individual messages: `gog gmail messages search 'is:unread from:someone@example.com' --max 10`
- Read email by ID: `gog gmail get <messageId>`
- Mark thread as read: `gog gmail thread modify <threadId> --remove UNREAD`
- **Approved recipients:** `paul@paultastic.com`, `c0achm77@gmail.com` — these are both Paul
- **Do NOT send to any other address without Paul's explicit permission**
- **Always confirm before sending** (per workspace safety rules in AGENTS.md)
