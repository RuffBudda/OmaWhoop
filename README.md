# WHOOP Rings for Omarchy

A desktop widget for the [Omarchy](https://omarchy.org) shell. It shows your latest
WHOOP **Sleep %**, **Recovery %** and **Strain (0–21)** as three rings on the wallpaper.

![WHOOP Rings in a red theme, with sample values](preview.png)

_Preview with sample values. Shown in a red accent; the widget uses your theme's accent colour._

- It sits on the wallpaper layer behind your windows. You see it on an empty workspace,
  and clicks pass through it to the desktop.
- It uses your theme's accent colour and font, and changes when you switch themes.
- It refreshes every 15 minutes. A ring shows `–` until WHOOP has scored that day.
- It stays hidden until WHOOP is connected, so turning it on before you set it up is harmless.
- Your WHOOP keys stay on your machine in `~/.config/whoop/` (mode 600). Nothing is sent
  anywhere except WHOOP's own API.

Plugin id: `ruffbudda.whoop` · kind: `service`

## Requirements

- Omarchy with the Quickshell shell and plugin system (`omarchy plugin …`). This is not a Waybar module.
- `python3` (standard library only) and `xdg-open`. Omarchy has both.
- A WHOOP account, plus a free WHOOP developer app (created in step 2 below).

## Install

```bash
omarchy plugin add https://github.com/RuffBudda/OmaWhoop.git --enable
```

## Connect WHOOP (once)

1. Go to <https://developer-dashboard.whoop.com> and sign in with your WHOOP account.
2. Create an app with:
   - **Redirect URI:** `http://localhost:8765/callback`
   - **Scopes:** `read:recovery`, `read:cycles`, `read:sleep`, `offline`
3. Run:

   ```bash
   ~/.config/omarchy/plugins/ruffbudda.whoop/scripts/whoop-auth
   ```

   Paste the app's Client ID and Client Secret when asked. The secret isn't shown as you type it.
   Your browser opens WHOOP; approve it, and the rings appear a moment later.

To use a different WHOOP app, delete `~/.config/whoop/client.json` and run `whoop-auth` again.

## Settings (optional)

Shell services don't get settings in `shell.json`, so the widget reads
`~/.config/whoop/widget.json` instead. Every key is optional, and changes apply as soon
as you save the file.

```json
{
  "corner": "top-left",
  "offsetX": 0,
  "offsetY": 0,
  "screen": "",
  "refreshMinutes": 15
}
```

| Key | Meaning | Default |
| --- | --- | --- |
| `corner` | `top-left`, `top-right`, `bottom-left` or `bottom-right` | `top-left` |
| `offsetX` / `offsetY` | Extra pixels away from the side and the top or bottom edge. Use these to stack the widget beside other desktop widgets. | `0` |
| `screen` | Output name, e.g. `DP-1` (see `hyprctl monitors`) | the laptop panel if on, else the first screen |
| `refreshMinutes` | How often to fetch from WHOOP (minimum 5) | `15` |

The widget keeps the same 12 px from the screen edge as Omarchy's default window gaps,
and stays below the bar.

## How it works

| File | What it does |
| --- | --- |
| `manifest.json` | Declares a `service` plugin with `keepLoaded: true`. |
| `Service.qml` | Runs the fetcher on a timer, watches `~/.cache/whoop.json`, and draws the rings in a click-through layer-shell window on the `bottom` layer. |
| `scripts/whoop-auth` | A one-time OAuth sign-in. It opens WHOOP in your browser, catches the reply on `127.0.0.1:8765`, checks the `state` value, and saves the tokens with mode 600. |
| `scripts/whoop-fetch` | Refreshes the access token when it expires, reads the latest scored recovery, cycle and sleep from WHOOP's v2 API, and writes `~/.cache/whoop.json` atomically. If WHOOP can't be reached, it keeps the last data. |

`whoop-fetch` exits with `2` while WHOOP isn't connected, and with `1` if WHOOP or the
network fails. Run it by hand to see why the rings are missing:

```bash
~/.config/omarchy/plugins/ruffbudda.whoop/scripts/whoop-fetch; echo $?
cat ~/.cache/whoop.json
```

Both scripts honour `XDG_CONFIG_HOME` and `XDG_CACHE_HOME`.

## Troubleshooting

- **No rings at all:** WHOOP isn't connected yet (run `whoop-auth`), or nothing has been
  scored yet. Run `whoop-fetch` by hand, as shown above.
- **`error 1010` / 403 from WHOOP:** Cloudflare blocked the request. The scripts already
  send their own User-Agent to avoid this, so try again in a few minutes.
- **`whoop-fetch` says the sign-in may have expired:** run `whoop-auth` again.
- **Port 8765 is in use:** close whatever is using it and run `whoop-auth` again. The
  redirect URI must match the one in your WHOOP app.
- **Shell errors:** `quickshell log --any-display -p /usr/share/omarchy/shell -t 80`

## Remove

```bash
omarchy plugin remove ruffbudda.whoop
rm -rf ~/.config/whoop ~/.cache/whoop.json   # also forget your WHOOP keys and data
```

You can also revoke the app's access in the WHOOP developer dashboard.

## Credits

Made by [RuffBudda](https://github.com/RuffBudda), originally for the
[DictatorOS](https://github.com/RuffBudda/DictatorOS) Omarchy setup. MIT licensed; see
[LICENSE](LICENSE). Not affiliated with or endorsed by WHOOP, Inc. WHOOP is a trademark of
WHOOP, Inc.
