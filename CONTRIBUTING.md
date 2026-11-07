# Contributing

Thanks for helping improve WHOOP Rings!

## Reporting bugs

Open an [issue](https://github.com/RuffBudda/OmaWhoop/issues/new/choose) and include:

- What you expected and what happened.
- The output of `~/.config/omarchy/plugins/ruffbudda.whoop/scripts/whoop-fetch; echo "exit $?"`.
- Any `ruffbudda.whoop` lines from `quickshell log --any-display -p /usr/share/omarchy/shell -t 80`.
- Your Omarchy version (`omarchy version`) and theme.

**Never paste anything from `~/.config/whoop/`** (Client Secret, tokens). For security
problems, see [SECURITY.md](SECURITY.md).

## Pull requests

1. Keep changes focused; one feature or fix per PR.
2. Run `tools/check` (it needs `jq`, `node`, `python3`, and Qt 6's `qmlformat` for the
   QML check) and, if you have Omarchy, `omarchy plugin validate .`.
3. Try it in a real Omarchy session: link your checkout into `~/.config/omarchy/plugins/`
   and run `omarchy restart shell`.
4. For a user-visible change, update `README.md` and add it under a new version in
   `CHANGELOG.md`. Bump `version` in `manifest.json` when releasing.

## Code style

- QML: follow the Omarchy shell's conventions. Import the palette as
  `import qs.Commons as Commons` and use `Commons.Color.*`, never bare `Color`.
- Keep colour logic in `Colors.js`, free of QML types, so it stays testable under Node.
  Add a test in `tests/colors.test.cjs` for any change to it.
- Scripts: Python 3 standard library only, no extra dependencies. Keep secrets at mode
  600 and never log them.
- No symlinks in the repo (Omarchy refuses them in plugins).

By contributing you agree that your work is released under the [MIT License](LICENSE).
