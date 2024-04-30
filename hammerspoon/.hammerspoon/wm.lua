hs.window.animationDuration = 0 -- less jitter
hs.window.filter.allowedWindowRoles = { AXStandardWindow = true } -- globally set window filters to ignore dialogs

local mode = "tile"
local focusedWindowByScreen = {}

local wf = hs.window.filter

local ratio = {
	current = 0.5,
	min = 0.3, -- less than this and Chrome gets squished
	max = 0.65, -- more than this and Slack gets squished
}

local logger = hs.logger.new("wm", "debug")

-- filtering by app name doesn't seem to work
-- so exclude apps by adding to this table
local float = {}
float["AWS VPN Client"] = 1

local function moveToRight(w)
	w:moveToUnit({ ratio.current, 0, 1 - ratio.current, 1 })
end

local function moveToLeft(w)
	w:moveToUnit({ 0, 0, ratio.current, 1 })
end

local function placeWindow(w)
	if mode == "monocle" then
		w:maximize()
		return
	end

	local app = w:application():name()

        if not float[app] then
	        logger:d("moved window, app: " .. app)
                moveToLeft(w)
        else
	        logger:d("float window, app: " .. app)
        end
end

wf.new():subscribe(wf.windowInCurrentSpace, placeWindow)

local function placeAll()
	for _, w in pairs(hs.window.visibleWindows()) do
		local screenId = w:screen():id()

                if mode == "tile" and w == focusedWindowByScreen[screenId] then
                        moveToRight(w)
                else
		        placeWindow(w)
                end
	end
end

return {
	mode = function(m)
		return function()
			mode = m
			placeAll()
		end
	end,
	toggleMode = function()
		if mode == "tile" then
			mode = "monocle"
		else
			mode = "tile"
		end
		placeAll()
	end,
	changeRatioBy = function(delta)
		return function()
			local new_ratio = ratio.current + delta
			if new_ratio >= ratio.min and new_ratio <= ratio.max then
				ratio.current = new_ratio
				placeAll()
			else
				logger:d("at ratio bounds!")
			end
			logger:d("ratio.current: " .. ratio.current)
		end
	end,
	makeFocusedMain = function()
                local focusedWindow = hs.window.focusedWindow()
		local screenId = focusedWindow:screen():id()
		focusedWindowByScreen[screenId] = focusedWindow
		logger:d(focusedWindowByScreen)
		moveToRight(focusedWindow)
	end,
}
