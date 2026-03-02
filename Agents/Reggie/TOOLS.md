# TOOLS.md - Local Notes

## Web Search

- **Provider:** Brave Search (configured in OpenClaw)
- **Best for:** General web queries, news, documentation
- **Tip:** Try multiple query formulations. Add year for recent results. Use quotes for exact phrases.

## Research Workflow

1. Start with broad search to map the landscape
2. Narrow to specific sources
3. Cross-reference across at least 2-3 sources
4. Note publication dates — freshness matters

## Output Locations

- Research findings → `/home/gunther/workspace/research/`
- Compiled reports → `/home/gunther/workspace/reports/`
- Filename format: `topic-YYYY-MM-DD.md`

## Report Template

```markdown
# [Topic] - Research Report

**Date:** YYYY-MM-DD
**Requested by:** [who asked]

## TL;DR
[2-3 sentence summary]

## Key Findings
- Finding 1
- Finding 2

## Details
[Full findings organized by subtopic]

## Sources

- [1] [https://domain.com/.../article-slug](https://domain.com/full/url) - Used for [specific data point or quote from this source]
- [2] [https://scholar.org/.../paper?date=2022-01](https://scholar.org/full/url) - Used for [specific data point or quote from this source]

<!-- URL display: keep domain + meaningful end (slug, date param). Truncate middle with ... if needed. Skip GUIDs. Full URL goes in the href so the link stays clickable. -->
```

## Email (Gmail via gog)

- Send plain text: `gog gmail send --to paul@paultastic.com --subject "Subject" --body "Message"`
- Send report as body: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-file ./path/to/report.md`
- Send via stdin (multi-line): `gog gmail send --to paul@paultastic.com --subject "Subject" --body-file - <<'EOF' ... EOF`
- Send HTML: `gog gmail send --to paul@paultastic.com --subject "Subject" --body-html "<p>HTML content</p>"`
- Search inbox: `gog gmail search 'newer_than:1d' --max 10`
- **Approved recipients:** `paul@paultastic.com`, `c0achm77@gmail.com`, `poliver@google.com` — these are all Paul
- **Do NOT send to any other address without Paul's explicit permission**
- **Always confirm before sending** (per workspace safety rules in AGENTS.md)

## Academic Paper Search

Direct access to structured academic databases via `~/workspace/scripts/papers.sh`. No API key or login required.

**Location:** `~/workspace/scripts/papers.sh`

| Source | Coverage | Best for |
|--------|----------|----------|
| Semantic Scholar | 200M+ papers, all fields | General academic search, citation counts |
| arXiv | CS, physics, math preprints | Cutting-edge STEM, not-yet-published work |
| CrossRef | Any DOI-registered publication | Metadata + links for specific papers |

### Subcommands

```bash
# Search Semantic Scholar (full-text search across 200M+ papers)
papers.sh search-scholar "transformer attention mechanism" 3

# Search arXiv preprints (CS, physics, math)
papers.sh search-arxiv "large language models" 5

# Look up any published paper by DOI
papers.sh doi "10.48550/arXiv.1706.03762"
```

Output: Plain text with title, authors, year, abstract snippet, and URL. Ready to cite directly.

### Tips

- **Start with Semantic Scholar** for broad academic coverage; fall back to arXiv for cutting-edge preprints
- **Default limit is 5**; pass a number (max 10) as the last argument to get more or fewer results
- **DOI lookup** works for any DOI-registered paper — conference papers, journals, preprints
- **DOIs from URLs:** `papers.sh doi` strips the `https://doi.org/` prefix automatically
- **arXiv preprint DOIs** (`10.48550/...`) may not be in CrossRef — if you get "not found", use `search-scholar` with the paper title instead
- **Combine with browse.sh:** Use `browse.sh get <url>` to fetch the full text of a paper once you have its URL

### When to use each

- **search-scholar**: "What papers exist on X?" — broad survey, recent work, well-known papers
- **search-arxiv**: Cutting-edge ML/CS/physics research published in the last 1–2 years
- **doi**: You have a specific DOI from a citation or reference and need the full metadata

## Web Browsing (Playwright)

Full Chromium browser for rendering JavaScript-heavy pages, interacting with elements, and taking screenshots. Use this when Brave Search results aren't enough and you need to actually load and interact with a web page.

**Location:** `~/workspace/scripts/browse.sh`

### Subcommands

```bash
# Fetch visible text content from a page (JS-rendered)
browse.sh get "https://www.costco.com/"

# Save a screenshot (returns /tmp/*.png path)
browse.sh screenshot "https://www.costco.com/"

# Click an element, return resulting page text
browse.sh click "https://example.com" "button#submit"

# Extract text from elements matching a CSS selector (returns JSON array)
browse.sh extract "https://news.ycombinator.com" "a.titlelink"

# Run a JavaScript expression on the page
browse.sh eval "https://example.com" "document.title"
```

### Tips

- **Large pages:** Use `extract` with a CSS selector instead of `get` to pull just the data you need (avoids flooding context with irrelevant text)
- **Layout-dependent info:** Use `screenshot` when you need to see how something looks visually
- **Multi-step flows:** Use `click` to navigate through pages that require interaction
- **Cookie persistence:** Sessions persist within `/tmp/playwright-reggie/` so cookies carry across commands within a task (cleared on reboot)
- **Timeout:** Each command has a 60-second hard limit — if a page is extremely slow, it will be killed

### Security

- **No credentials:** Never enter passwords or auth tokens through browse.sh without Paul's explicit approval
- **Private IPs blocked:** Requests to localhost, 127.*, 10.*, 192.168.*, and 172.16-31.* are rejected
- **Ephemeral data:** Browser data lives in `/tmp/` and is wiped on reboot

### Troubleshooting

- **"Browser closed" or "Executable doesn't exist":** Run `cd /home/gunther/tools/playwright && npx playwright install chromium` to reinstall
- **Page loads but shows "enable JavaScript":** This shouldn't happen (full Chromium), but try increasing the wait by using `eval` with a delay
- **Timeout errors:** The page may be too slow or blocking automated browsers; try `screenshot` to see what loaded
