-- reduction of https://github.com/Hammerspoon/hammerspoon/issues/856
local currentWindowSet = {}
local windowCycler = nil

local function makeTableCycler(t)
	local i = 1
	return function(d)
		local j = d and d < 0 and -2 or 0
		i = (i + j) % #t + 1
		return t[i]
	end
end

local function updateWindowCycler()
	if not hs.fnutils.contains(currentWindowSet, hs.window.focusedWindow()) then
		-- TODO exclude empty Finder
		currentWindowSet = hs.window.orderedWindows() -- current space only
		windowCycler = makeTableCycler(currentWindowSet)
	end
end

local focusNextWindow = function()
	updateWindowCycler()
	windowCycler():focus()
end

local focusPrevWindow = function()
	updateWindowCycler()
	windowCycler(-1):focus()
end

return {
	focusNextWindow = function()
		focusNextWindow()
	end,
	focusPrevWindow = function()
		focusPrevWindow()
	end,
}
