# Changelog

All notable changes to WHOOP Rings are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [1.1.0] - 2026-11-07

### Added
- **System colours.** Every colour can be a live theme role (`accent`, `foreground`,
  `background`, `muted`, `urgent`), any key from the active theme's `colors.toml`
  (`green`, `bright_blue`, …) or a hex value. Colours follow `omarchy theme set` live.
- `colors` settings: `ring`, `sleep`, `recovery`, `strain`, `value`, `label`, `box`,
  `boxOpacity` and `trackOpacity`.
- `recoveryZones`: colours the recovery ring by WHOOP zone in the theme's green, yellow and red.
- `examples/widget.json`, `tools/check`, colour tests and a GitHub Actions check.
- A full README with badges and previews, plus CHANGELOG, CONTRIBUTING and SECURITY files
  and issue templates.

## [1.0.0] - 2026-11-07

### Added
- First release as a standalone Omarchy plugin (`ruffbudda.whoop`), split out of DictatorOS.
- Sleep %, Recovery % and Strain rings on the wallpaper layer, in the theme's accent colour.
- `scripts/whoop-auth` (one-time OAuth sign-in) and `scripts/whoop-fetch` (token refresh and
  data fetch), which run from the plugin folder.
- Optional `~/.config/whoop/widget.json` for corner, offsets, screen and refresh interval.

[1.1.0]: https://github.com/RuffBudda/OmaWhoop/releases/tag/v1.1.0
[1.0.0]: https://github.com/RuffBudda/OmaWhoop/releases/tag/v1.0.0
