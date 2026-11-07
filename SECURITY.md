# Security policy

## Supported versions

Only the latest release gets fixes. Update with `omarchy plugin update ruffbudda.whoop`.

## Reporting a vulnerability

Please **don't open a public issue** for security problems. Report them privately via
GitHub's [private vulnerability reporting](https://github.com/RuffBudda/OmaWhoop/security/advisories/new).
Include steps to reproduce and the affected version. You should get a reply within a week.

## What the plugin handles

- Your WHOOP developer app's Client ID and Client Secret, and the OAuth tokens. These are
  stored in `~/.config/whoop/` (folder mode 700, files mode 600) and sent only to
  `api.prod.whoop.com`.
- During `whoop-auth`, a one-request HTTP server on `127.0.0.1:8765` that checks a random
  `state` value.
- WHOOP scores cached in `~/.cache/whoop.json` (no secrets).

If you think your tokens have leaked, revoke the app in the
[WHOOP developer dashboard](https://developer-dashboard.whoop.com), delete
`~/.config/whoop/`, and run `whoop-auth` again.
