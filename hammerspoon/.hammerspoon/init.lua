local shiv = require("shiv")
local wm = require("wm")
local wswitcher = require("wswitcher")

------------------
-- Key bindings --
------------------

-- Window management

hs.hotkey.bind("alt", "T", wm.mode("tile"))
hs.hotkey.bind("alt", "M", wm.mode("monocle"))
hs.hotkey.bind("alt", hs.keycodes.map["return"], wm.makeFocusedMain)
hs.hotkey.bind("alt", hs.keycodes.map["space"], wm.toggleMode)

hs.hotkey.bind("alt", "H", wm.changeRatioBy(-0.05))
hs.hotkey.bind("alt", "L", wm.changeRatioBy(0.05))

hs.hotkey.bind("alt", "J", wswitcher.focusNextWindow)
hs.hotkey.bind("alt", "K", wswitcher.focusPrevWindow)

-- Slack hotkeys
-- Unreads
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "1",
  shiv("Slack", {"cmd", "shift"}, "A")
)
-- Threads
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "2",
  shiv("Slack", {"cmd", "shift"}, "T")
)
