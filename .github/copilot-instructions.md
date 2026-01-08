<!-- Copilot/AI agent instructions for CardCollectables -->
# CardCollectables — AI agent instructions

This repository is a small, static website (HTML/CSS/vanilla JS) for CardCollectables. The guidance below focuses on patterns, conventions, and concrete examples an AI agent needs to be immediately productive editing this codebase.

## Big picture
- **Architecture:** Plain static site. Files live at the repo root: `index.html`, `Submission.html`, `About.html`, `WhatsNew.html`, `thank-you.html`, an `images/` directory, and small JSON status files (`bulk-status-*.json`). No build toolchain, no server-side code in repo.
- **Runtime behavior:** Client-side JS handles UI, calculates estimates in `Submission.html`, posts JSON to an external Formspree endpoint, and reads `bulk-status.json` to enable/disable submissions.

## Key files and patterns (examples)
- `Submission.html` — central interactive page. Important bits:
  - Fetches `./bulk-status.json` at page load to set `submissionsOpen` and optionally insert a `.bulk-alert` element.
  - Form calculation relies on `tbody tr` rows with `data-price="..."`, input elements, `.row-total` cells, and totals shown in `#total-qty` and `#grand-total`.
  - Submission payload to Formspree includes: `submission_id`, `total_quantity`, `estimated_value` (string with £), and `breakdown` (comma-separated string).
  - Client-generated IDs: `generateSubmissionId()` uses `localStorage` key `cc-counter-<DDMMYY>` and stores the current id in `sessionStorage` as `submission_id`.
  - The external endpoint is the `endpoint` variable near the bottom of `Submission.html` (update carefully if changing provider).
- `bulk-status-open.json` / `bulk-status-closed.json` — two variants present in the repo. The running site expects a single `bulk-status.json` at root; during deployment ensure the correct variant is present as `bulk-status.json`.

## Concrete editing conventions
- Keep markup, CSS, and JS in the same HTML file (this repo uses inlined CSS/JS). When making edits, update both desktop and mobile nav markup if applicable (they are duplicated in `header`).
- Pricing table rows are data-driven via `data-price` attributes; prefer updating `data-price` values and row labels instead of changing JS logic.
- Use the existing CSS variables defined at the top of `Submission.html` for colors and spacing (e.g., `--blue-primary`, `--border`) to keep styling consistent.

## Developer workflows and commands
- There is no build step. To preview locally, run a simple static server from the repo root.

PowerShell example (from repo root):
```powershell
# start a simple http server on port 8000
python -m http.server 8000
# then open http://localhost:8000/ in a browser
```

- Alternative: use the VS Code Live Server extension for instant reload.
- To toggle submission availability locally or before deployment, copy the desired variant to `bulk-status.json`:
```powershell
# enable submissions
copy .\bulk-status-open.json .\bulk-status.json; # PowerShell
# disable submissions
copy .\bulk-status-closed.json .\bulk-status.json;
```

## Integration points and external dependencies
- External form submission: `https://formspree.io/f/xrebewld` (see `endpoint` in `Submission.html`). Changing providers requires updating that URL and verifying payload compatibility.
- `bulk-status.json` controls whether the submit button is enabled and whether an alert is shown. The site expects this JSON with keys: `{ "open": boolean, "message": string }` (see `bulk-status-*.json` examples).

## Debugging pointers
- To troubleshoot totals or row behavior, inspect rows with `document.querySelectorAll('tbody tr')`, confirm each row has `data-price`, inputs are numeric, and `.row-total` updates on `input` events.
- To debug submission flow: verify `generateSubmissionId()` output, check `localStorage` keys `cc-counter-<date>`, confirm fetch to Formspree returns success, and ensure redirect to `thank-you.html` occurs.

## What to watch for / gotchas
- File names are referenced as relative paths in HTML; hosting is case-sensitive — preserve exact filenames (e.g., `images/LogoFull.png`).
- There are two bulk-status files in the repo. The client code requests `bulk-status.json` — ensure deployment produces that filename.
- Because JS is inlined, updates to shared behavior across pages may require editing multiple files that duplicate logic.

## When to ask for human input
- If you need to change the external submission endpoint, ask which service/account to use and whether payload keys should change.
- If a deploy process is added that replaces `bulk-status.json`, ask for the deployment mechanism to ensure the correct variant is used.

If any of the above assumptions are incorrect or you want me to include other files as examples, tell me which files to inspect next and I'll iterate.
