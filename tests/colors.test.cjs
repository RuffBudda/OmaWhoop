// Tests for Colors.js. Run: node tests/colors.test.cjs
"use strict"
const fs = require("fs")
const path = require("path")
const assert = require("assert")

// Colors.js is a QML JavaScript library: drop the .pragma line and expose its functions.
const src = fs.readFileSync(path.join(__dirname, "..", "Colors.js"), "utf8").replace(/^\.pragma library\s*$/m, "")
const C = new Function(src + "\nreturn { ROLES, isHex, parsePalette, resolve, zone, zoneColor, clamp01 }")()

let passed = 0
function test(name, fn) { fn(); passed++; console.log("ok - " + name) }

const toml = `
# "Red" — a theme comment with a # in it
mode = "dark"
accent = "#e5383b"   # trailing comment
green = '#d9534f'
bright_blue = "#ff4d4f"
not_a_colour = "hello"
size = 12
[terminal]
color4 = "#112233"
`
const palette = C.parsePalette(toml)
const roles = { accent: "#e5383b", foreground: "#e8d5d6", background: "#000000", muted: "#5c1a1e", urgent: "#a55555" }

test("parsePalette reads hex keys and skips the rest", () => {
  assert.strictEqual(palette.accent, "#e5383b")
  assert.strictEqual(palette.green, "#d9534f")
  assert.strictEqual(palette.bright_blue, "#ff4d4f")
  assert.strictEqual(palette["terminal.color4"], "#112233")
  assert.strictEqual(palette.mode, undefined)
  assert.strictEqual(palette.not_a_colour, undefined)
  assert.strictEqual(palette.size, undefined)
})

test("parsePalette tolerates junk", () => {
  assert.deepStrictEqual(C.parsePalette(undefined), {})
  assert.deepStrictEqual(C.parsePalette(""), {})
})

test("resolve: empty or unknown uses the fallback", () => {
  assert.strictEqual(C.resolve(undefined, roles, palette, "FB"), "FB")
  assert.strictEqual(C.resolve("", roles, palette, "FB"), "FB")
  assert.strictEqual(C.resolve("no-such-colour", roles, palette, "FB"), "FB")
  assert.strictEqual(C.resolve(42, roles, palette, "FB"), "FB")
})

test("resolve: theme roles", () => {
  assert.strictEqual(C.resolve("foreground", roles, palette, "FB"), "#e8d5d6")
  assert.strictEqual(C.resolve("Muted", roles, palette, "FB"), "#5c1a1e")
})

test("resolve: colors.toml keys, dashes or underscores", () => {
  assert.strictEqual(C.resolve("green", roles, palette, "FB"), "#d9534f")
  assert.strictEqual(C.resolve("bright-blue", roles, palette, "FB"), "#ff4d4f")
  assert.strictEqual(C.resolve("terminal.color4", roles, palette, "FB"), "#112233")
})

test("resolve: hex values pass through, bad hex falls back", () => {
  assert.strictEqual(C.resolve("#abc", roles, palette, "FB"), "#abc")
  assert.strictEqual(C.resolve("#80ff0000", roles, palette, "FB"), "#80ff0000")
  assert.strictEqual(C.resolve("#ggg", roles, palette, "FB"), "FB")
})

test("zone boundaries match WHOOP", () => {
  assert.strictEqual(C.zone(0), "red")
  assert.strictEqual(C.zone(33), "red")
  assert.strictEqual(C.zone(34), "yellow")
  assert.strictEqual(C.zone(66), "yellow")
  assert.strictEqual(C.zone(67), "green")
  assert.strictEqual(C.zone(100), "green")
  assert.strictEqual(C.zone(null), "")
})

test("zoneColor prefers the theme, then WHOOP's colours", () => {
  assert.strictEqual(C.zoneColor(80, palette, "FB"), "#d9534f")
  assert.strictEqual(C.zoneColor(50, palette, "FB"), "#ffde00")
  assert.strictEqual(C.zoneColor(undefined, palette, "FB"), "FB")
})

test("clamp01", () => {
  assert.strictEqual(C.clamp01(2, 0.5), 1)
  assert.strictEqual(C.clamp01(-1, 0.5), 0)
  assert.strictEqual(C.clamp01("x", 0.5), 0.5)
})

console.log(`\n${passed} tests passed`)
