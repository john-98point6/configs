hs.window.animationDuration = 0 -- less jitter
hs.window.filter.allowedWindowRoles = { AXStandardWindow = true } -- globally set window filters to ignore dialogs

local function moveToRight(state, w)
	w:moveToUnit({ state.ratio, 0, 1 - state.ratio, 1 })
end

local function moveToLeft(state, w)
	w:moveToUnit({ 0, 0, state.ratio, 1 })
end

local function moveToTop(state, w)
	w:moveToUnit({ 0, 0, 1, state.ratio })
end

local function moveToBottom(state, w)
	w:moveToUnit({ 0, state.ratio, 1, 1 - state.ratio })
end

local ratio = {
	min = 0.3, -- less than this and Chrome gets squished
	max = 0.65, -- more than this and Slack gets squished
}

local tileStrategy = {
	horizontal = function(state, w)
        if w == state.focusedWindow then
			moveToRight(state, w)
		else
			moveToLeft(state, w)
		end
	end,
	vertical = function(state, w)
        if w == state.focusedWindow then
			moveToTop(state, w)
		else
			moveToBottom(state, w)
		end
	end,
}

local screenState = {}
for _, s in pairs(hs.screen.allScreens()) do
	screenState[s:id()] = {
		mode = "tile",
		ratio = 0.5,
		focusedWindow = nil
	}
end
screenState[1].tileStrategy = tileStrategy.horizontal
screenState[2].tileStrategy = tileStrategy.vertical

local wf = hs.window.filter

local logger = hs.logger.new("wm", "debug")

-- filtering by app name doesn't seem to work
-- so exclude apps by adding to this table
local float = {}
float["AWS VPN Client"] = 1



local function placeWindow(w)
	local state = screenState[w:screen():id()]
	if state.mode == "monocle" then
		w:maximize()
		return
	end

	local app = w:application():name()
	if float[app] then
		logger:d("float window, app: " .. app)
		return
	end

	state.tileStrategy(state, w)
	logger:d("moved window, app: " .. app)
end

wf.new():subscribe(wf.windowInCurrentSpace, placeWindow)

local function placeAll()
	for _, w in pairs(hs.window.visibleWindows()) do
		placeWindow(w)
        -- end
	end
end

return {
	mode = function(mode)
		return function()
		local state = screenState[hs.screen.mainScreen():id()]
			state.mode = mode
			placeAll()
		end
	end,
	toggleMode = function()
		local state = screenState[hs.screen.mainScreen():id()]
		if state.mode == "tile" then
			state.mode = "monocle"
		else
			state.mode = "tile"
		end
		placeAll()
	end,
	changeRatioBy = function(delta)
		return function()
			local currentScreen = hs.screen.mainScreen()
			local screenId = currentScreen:id()
			local newRatio = screenState[screenId].ratio + delta
			if newRatio >= ratio.min and newRatio <= ratio.max then
				screenState[screenId].ratio = newRatio
				placeAll()
			else
				logger:d("at ratio bounds!")
			end
		end
	end,
	makeFocusedMain = function()
                local focusedWindow = hs.window.focusedWindow()
		local state = screenState[focusedWindow:screen():id()]
		state.focusedWindow = focusedWindow
	placeWindow(focusedWindow)
	end,
}
