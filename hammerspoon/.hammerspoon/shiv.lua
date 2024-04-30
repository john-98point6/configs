-- shiv
-- focus an app and send a key command

local delay = 0.1

return function(appName, mods, key)
  return function()
    hs.application.launchOrFocus(appName)
      local focusedWindow = hs.window.focusedWindow()
      while focusedWindow:application():name() ~= appName do
        hs.timer.doAfter(delay, function() 
          focusedWindow = hs.window.focusedWindow()
        end)
      end
  
    hs.eventtap.keyStroke(mods, key)
  end
end