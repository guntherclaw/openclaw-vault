# TOOLS.md - Local Notes

## Web Search

- **Provider:** Brave Search (configured in OpenClaw)
- **Best for:** Finding current statistics, recent news, verifying facts before citing them in arguments
- **Tip:** Use targeted queries. "Thomas Sowell capitalism poverty data" beats "capitalism good". Add a year for fresh results.

## Web Browsing (Playwright)

Full Chromium browser for reading JavaScript-heavy pages. Use this when you need to actually read a full article, Reddit thread, or X post that Paul links or that came up in search.

**Location:** `~/workspace/scripts/browse.sh`

### Subcommands

```bash
# Fetch visible text from a page (JS-rendered)
browse.sh get "https://www.reddit.com/r/..."

# Save a screenshot (returns /tmp/*.png path)
browse.sh screenshot "https://..."

# Extract text from elements matching a CSS selector
browse.sh extract "https://news.ycombinator.com" "a.titlelink"
```

### Use cases for Charlie

- Reading a full news article Paul references in a debate
- Checking a Reddit thread for context on an argument Paul is engaging with
- Verifying a claim before citing it (read the actual source)
- Checking a public X post Paul wants to respond to

### Tips

- **Reddit:** `browse.sh get "https://reddit.com/r/[subreddit]/comments/..."` works well for reading threads
- **X (Twitter):** Public posts are readable at `x.com` — use `browse.sh get` on the direct post URL
- **Large pages:** Use `extract` with a CSS selector to pull just the content you need
- **Timeout:** 60-second hard limit per command

### Security

- No credentials. Never enter passwords or auth tokens.
- Private IPs blocked.
- Browser data lives in `/tmp/` and is wiped on reboot.

## Academic Paper Search

Direct access to structured academic databases via `~/workspace/scripts/papers.sh`. No API key or login required.

**Location:** `~/workspace/scripts/papers.sh`

| Source | Coverage | Best for |
|--------|----------|----------|
| Semantic Scholar | 200M+ papers, all fields | Theology, economics, political science, social science |
| arXiv | CS, physics, math preprints | Cutting-edge STEM claims (climate, AI, medicine) |
| CrossRef | Any DOI-registered publication | Metadata + links for a specific paper you already have |

### Subcommands

```bash
# Search Semantic Scholar
papers.sh search-scholar "capitalism poverty reduction developing nations" 3

# Search arXiv preprints
papers.sh search-arxiv "AI safety alignment" 5

# Look up a specific paper by DOI
papers.sh doi "10.1257/aer.20150645"
```

Output: Plain text with title, authors, year, abstract snippet, and URL. Ready to cite.

### Tips

- **Start with Semantic Scholar** for theology, economics, political philosophy
- **Default limit is 5**; pass a number (max 10) as last argument
- **DOI lookup** works for journals, conference papers, and preprints
- **Combine with browse.sh:** Use `browse.sh get <url>` to fetch full text of a paper
- **Only cite what you've verified** — fetch the source and confirm what it actually says before quoting it

### When to use

- You need an empirical anchor for an economic or social claim (Sowell-style data)
- You need to verify a statistic before citing it in an argument
- You want to find a peer-reviewed counterpoint to cite against an opponent's source

## Email (Gmail via gog)

- Send plain text: `gog gmail send --to paul@paultastic.com --subject "Subject" --body "Message"`
- Send report as body: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-file ./path/to/file.md`
- Send via stdin: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-file - <<'EOF' ... EOF`
- **Approved recipients ONLY:** `paul@paultastic.com`, `poliver@google.com`, `c0achm77@gmail.com` — these are all Paul
- **Do NOT send to any other address without Paul's explicit permission**
- **Always confirm before sending** (per workspace safety rules in AGENTS.md)

## Output Locations

- Crafted arguments / long-form pieces → `/home/gunther/workspace/files/`
- Filename format: `YYYY-MM-DD-short-description.md`
