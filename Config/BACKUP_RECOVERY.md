# Backup & Recovery Guide

**Created:** 2026-03-02
**Vault root:** `~/workspace/vault/`

This document covers how to recover each layer of the OpenClaw system from backup.

---

## Recovery Layers

The system has three distinct recovery layers, each restored from a different source.
Restore them in order: **config → vault → runtime → restart**.

---

## Layer 1: OpenClaw Config Recovery

Source: `~/projects/openclaw-config` (git repo, stow-managed)

```bash
# Clone the config repo (if missing)
git clone git@github.com:guntherclaw/openclaw-config ~/projects/openclaw-config

# Re-deploy symlinks
cd ~/projects/openclaw-config
stow --ignore='jobs\.json' -t /home/gunther home

# Restore secrets manually (not in git)
# Copy ~/.openclaw/.env from a secure backup location
```

**What this covers:** `openclaw.json`, all agent bootstrap files (`SOUL.md`, `AGENTS.md`,
`IDENTITY.md`, `HEARTBEAT.md`, etc.), workspace root files.

---

## Layer 2: Vault Recovery

Source: `git@github.com:guntherclaw/openclaw-vault`

```bash
git clone git@github.com:guntherclaw/openclaw-vault ~/workspace/vault
```

**What this covers:** Obsidian vault contents — agent identity docs, config docs,
roadmap, task format reference. This is the canonical record of agent identities
and system config documentation.

After cloning, open the vault in Obsidian and verify plugins load correctly.

---

## Layer 3: Runtime State Recovery

Source: rclone remote `gunther-openclaw-workspace`

```bash
# Preview what will be restored
rclone ls gunther-openclaw-workspace:

# Restore full workspace (dry run first)
rclone sync gunther-openclaw-workspace: ~/workspace/ --dry-run

# Restore for real
rclone sync gunther-openclaw-workspace: ~/workspace/
```

**What this covers:** Agent task folders (`inbox/`, `inprogress/`, `blocked/`,
`outbox/`, `done/`), session data, logs, memory files, brain notes, reports,
and any other runtime state not tracked in git.

**Note:** The vault itself (`~/workspace/vault/`) is excluded from the rclone
backup since it's covered by the git remote. The rclone sync restores everything
else under `~/workspace/`.

---

## Full System Recovery Order

1. **Config** — re-stow from `openclaw-config` repo, restore `.env` secrets
2. **Vault** — `git clone` the vault repo
3. **Runtime** — `rclone sync` from `gunther-openclaw-workspace`
4. **Restart** — start OpenClaw; agents reconnect to their Telegram bots

```bash
# Quick reference sequence
git clone git@github.com:guntherclaw/openclaw-config ~/projects/openclaw-config
cd ~/projects/openclaw-config && stow --ignore='jobs\.json' -t /home/gunther home
# restore ~/.openclaw/.env manually
git clone git@github.com:guntherclaw/openclaw-vault ~/workspace/vault
rclone sync gunther-openclaw-workspace: ~/workspace/
# start OpenClaw
```
