.pragma library
// Colour helpers for WHOOP Rings. Plain JavaScript with no QML types, so the
// tests can load it under Node (tests/colors.test.cjs).

// Names that map to the shell's live theme roles (Commons.Color).
var ROLES = ["accent", "foreground", "background", "muted", "urgent"]

// WHOOP's recovery zones: red 0-33, yellow 34-66, green 67-100.
var ZONE_FALLBACK = { red: "#ff0026", yellow: "#ffde00", green: "#16ec06" }

function isHex(s) {
  return typeof s === "string" && /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(s)
}

// Reads the `key = "#hex"` lines of an Omarchy colors.toml (the active
// theme's palette). Section headers and anything that isn't a colour are skipped.
function parsePalette(text) {
  var out = {}
  if (typeof text !== "string") return out
  var lines = text.split(/\r?\n/)
  var section = ""
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    var sec = /^\s*\[([^\]]+)\]\s*(#.*)?$/.exec(line)
    if (sec) { section = sec[1].trim() + "."; continue }
    var m = /^\s*([A-Za-z0-9_.-]+)\s*=\s*["'](#[0-9a-fA-F]{3,8})["']\s*(#.*)?$/.exec(line)
    if (m && isHex(m[2])) out[section + m[1]] = m[2]
  }
  return out
}

// Turns a colour setting into a colour string.
//   value    "accent" | "foreground" | ... (a theme role), a colors.toml key
//            such as "green" or "bright_blue", or "#rrggbb" / "#aarrggbb"
//   roles    { accent: ..., foreground: ..., ... } from the live theme
//   palette  parsePalette() of the active theme's colors.toml
//   fallback the colour to use when value is empty or unknown
function resolve(value, roles, palette, fallback) {
  if (typeof value !== "string" || value === "") return fallback
  var v = value.trim()
  if (isHex(v)) return v
  var key = v.toLowerCase().replace(/-/g, "_")
  if (ROLES.indexOf(key) >= 0 && roles && roles[key] !== undefined && roles[key] !== null) return roles[key]
  if (palette && palette[key] !== undefined) return palette[key]
  if (palette && palette[v] !== undefined) return palette[v]
  return fallback
}

function zone(recovery) {
  if (typeof recovery !== "number" || !isFinite(recovery)) return ""
  return recovery >= 67 ? "green" : recovery >= 34 ? "yellow" : "red"
}

// The recovery ring's colour by WHOOP zone, using the theme's own green /
// yellow / red (or WHOOP's colours when the theme has none).
function zoneColor(recovery, palette, fallback) {
  var z = zone(recovery)
  if (z === "") return fallback
  if (palette && palette[z] !== undefined) return palette[z]
  return ZONE_FALLBACK[z]
}

function clamp01(x, fallback) {
  return typeof x === "number" && isFinite(x) ? Math.max(0, Math.min(1, x)) : fallback
}
