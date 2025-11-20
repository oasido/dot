-- detect display configuration changes
function updateDockPosition()
	-- get count of all screens (built-in + external)
	local screenCount = #hs.screen.allScreens()

	-- if only one screen, dock on left
	-- if more than one screen, dock on bottom
	if screenCount == 1 then
		hs.execute("defaults write com.apple.dock orientation left && killall Dock")
	else
		hs.execute("defaults write com.apple.dock orientation bottom && killall Dock")
	end
end

-- run when displays are connected or disconnected
hs.screen.watcher.new(updateDockPosition):start()

-- run once on startup
updateDockPosition()

