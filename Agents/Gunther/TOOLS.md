# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Email (Gmail via gog)

- Send plain text: `gog gmail send --to paul@paultastic.com --subject "Subject" --body "Message"`
- Send file as body: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-file ./path/to/file.md`
- Send via stdin (multi-line): `gog gmail send --to paul@paultastic.com --subject "Subject" --body-file - <<'EOF' ... EOF`
- Send HTML: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-html "<p>HTML content</p>"`
- Create draft (for review): `gog gmail drafts create --to paul@paultastic.com --subject "Subject" --body-file ./file.md`
- Send draft: `gog gmail drafts send <draftId>`
- Search inbox: `gog gmail search 'newer_than:1d' --max 10`
- **Approved recipients:** `paul@paultastic.com`, `c0achm77@gmail.com` — these are both Paul
- **Do NOT send to any other address without Paul's explicit permission**
- **Always confirm before sending** (per workspace safety rules in AGENTS.md)
