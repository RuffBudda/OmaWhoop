// WHOOP Rings: a desktop widget showing your latest WHOOP sleep %, recovery %
// and strain (0-21) as three rings on the wallpaper layer, behind windows.
//
// Data comes from scripts/whoop-fetch (bundled with this plugin), which writes
// ~/.cache/whoop.json. The widget stays hidden until you connect WHOOP once
// with scripts/whoop-auth. Optional placement: ~/.config/whoop/widget.json
// (see README).
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons

Item {
  id: root
  property var shell: null
  property var manifest: null

  readonly property string home: Quickshell.env("HOME")
  readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || (home + "/.config")) + "/whoop"
  readonly property string cacheFile: (Quickshell.env("XDG_CACHE_HOME") || (home + "/.cache")) + "/whoop.json"
  // The fetcher ships next to this file, wherever the plugin is installed.
  readonly property string fetcher: decodeURIComponent(Qt.resolvedUrl("scripts/whoop-fetch").toString().replace(/^file:\/\//, ""))

  // ---- Settings (from ~/.config/whoop/widget.json, all optional) ----------
  property string corner: "top-left"   // top-left | top-right | bottom-left | bottom-right
  property int offsetX: 0              // extra px away from the side edge
  property int offsetY: 0              // extra px away from the top/bottom edge
  property string screenName: ""       // e.g. "DP-1"; empty = laptop panel, else first screen
  property int refreshMinutes: 15      // at least 5

  // Spacing matches Omarchy's default window gaps (gaps_out 10 + 2 px border).
  readonly property int edgeGap: 12
  readonly property int pad: 12
  readonly property int boxHeight: 145
  readonly property int ringGap: 28
  readonly property real ringSize: Math.max(40, Math.floor((boxHeight - 2 * pad - 16) / 1.1))

  function applySettings(text) {
    var s = {}
    try { s = JSON.parse(text) || {} } catch (e) { s = {} }
    var corners = ["top-left", "top-right", "bottom-left", "bottom-right"]
    root.corner = corners.indexOf(s.corner) >= 0 ? s.corner : "top-left"
    root.offsetX = Number.isFinite(s.offsetX) ? Math.round(s.offsetX) : 0
    root.offsetY = Number.isFinite(s.offsetY) ? Math.round(s.offsetY) : 0
    root.screenName = typeof s.screen === "string" ? s.screen : ""
    root.refreshMinutes = Number.isFinite(s.refreshMinutes) ? Math.max(5, Math.round(s.refreshMinutes)) : 15
  }

  FileView {
    path: root.configDir + "/widget.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.applySettings(text())
    onLoadFailed: root.applySettings("")
  }

  // ---- Data ----------------------------------------------------------------
  property var whoop: null
  readonly property bool ready: whoop !== null
    && (has(whoop.recovery) || has(whoop.strain) || has(whoop.sleep))

  function has(v) { return v !== null && v !== undefined }

  FileView {
    path: root.cacheFile
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: { try { root.whoop = JSON.parse(text()) } catch (e) { root.whoop = null } }
    onLoadFailed: root.whoop = null
  }

  Process { id: fetchProc; command: [root.fetcher] }

  Timer {
    interval: root.refreshMinutes * 60 * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!fetchProc.running) fetchProc.running = true
  }

  // ---- Screen --------------------------------------------------------------
  readonly property var targetScreen: {
    var s = Quickshell.screens
    if (root.screenName !== "")
      for (var k = 0; k < s.length; k++) if (s[k].name === root.screenName) return s[k]
    for (var i = 0; i < s.length; i++)
      if (/^(eDP|LVDS|DSI)-/.test(s[i].name)) return s[i]
    return s.length > 0 ? s[0] : null
  }

  // ---- Ring ----------------------------------------------------------------
  component Ring: Column {
    id: ring
    property real value: 0      // shown number
    property real fraction: 0   // 0..1 of the ring filled
    property string label: ""
    property bool percent: true
    property bool hasValue: true
    property real size: 64
    spacing: Math.round(size * 0.1)

    Item {
      width: ring.size; height: ring.size
      anchors.horizontalCenter: parent.horizontalCenter
      Canvas {
        anchors.fill: parent
        property real f: ring.hasValue ? Math.max(0, Math.min(1, ring.fraction)) : 0
        property color accent: Commons.Color.accent
        onFChanged: requestPaint()
        onAccentChanged: requestPaint()
        onPaint: {
          var ctx = getContext("2d"); ctx.reset()
          var lw = Math.max(4, ring.size * 0.09)
          var c = width / 2, r = c - lw / 2 - 1, a = accent
          ctx.lineWidth = lw; ctx.lineCap = "round"
          ctx.strokeStyle = Qt.rgba(a.r, a.g, a.b, 0.15)
          ctx.beginPath(); ctx.arc(c, c, r, 0, 2 * Math.PI); ctx.stroke()
          if (f > 0) {
            ctx.strokeStyle = a
            ctx.beginPath(); ctx.arc(c, c, r, -Math.PI / 2, -Math.PI / 2 + f * 2 * Math.PI); ctx.stroke()
          }
        }
      }
      Text {
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: ring.hasValue ? (ring.percent ? Math.round(ring.value) + "%" : ring.value.toFixed(1)) : "–"
        color: Commons.Color.accent
        font.family: Style.font.family
        font.pixelSize: Math.round(ring.size * 0.2)
        font.weight: Font.DemiBold
      }
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: ring.label
      color: Commons.Color.accent
      font.family: Style.font.family
      font.pixelSize: 12
      font.letterSpacing: 1
    }
  }

  // ---- Window --------------------------------------------------------------
  PanelWindow {
    screen: root.targetScreen
    visible: root.ready && root.targetScreen !== null
    anchors {
      top: root.corner.indexOf("top") === 0
      bottom: root.corner.indexOf("bottom") === 0
      left: root.corner.indexOf("left") > 0
      right: root.corner.indexOf("right") > 0
    }
    margins {
      top: root.edgeGap + root.offsetY
      bottom: root.edgeGap + root.offsetY
      left: root.edgeGap + root.offsetX
      right: root.edgeGap + root.offsetX
    }
    implicitWidth: frame.width
    implicitHeight: frame.height
    color: "transparent"
    exclusionMode: ExclusionMode.Normal        // stay below the bar, reserve no space
    WlrLayershell.layer: WlrLayer.Bottom       // on the wallpaper, behind windows
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "ruffbudda-whoop"
    mask: Region {}                            // clicks pass through to the desktop

    Rectangle {
      id: frame
      width: ringsRow.implicitWidth + 2 * root.pad
      height: root.boxHeight
      radius: Style.cornerRadius
      color: Qt.rgba(0, 0, 0, 0.35)

      Row {
        id: ringsRow
        anchors.centerIn: parent
        spacing: root.ringGap
        Ring {
          size: root.ringSize
          label: "SLEEP"
          hasValue: root.ready && root.has(root.whoop.sleep)
          value: hasValue ? root.whoop.sleep : 0
          fraction: value / 100
        }
        Ring {
          size: root.ringSize
          label: "RECOVERY"
          hasValue: root.ready && root.has(root.whoop.recovery)
          value: hasValue ? root.whoop.recovery : 0
          fraction: value / 100
        }
        Ring {
          size: root.ringSize
          label: "STRAIN"
          percent: false
          hasValue: root.ready && root.has(root.whoop.strain)
          value: hasValue ? root.whoop.strain : 0
          fraction: value / 21
        }
      }
    }
  }
}
