-- audio-auto-switch.lua
-- switches default input to insta360 when both the dock mic and jbl are connected
-- prevents macos from forcing the jbl into hfp/hsp profile which destroys audio quality

-- device names must match exactly as shown in audio midi setup utility
local MIC_NAME = "Insta360 Link 2C"
local HEADPHONES_NAMES = {
	"JBL Tune 720BT",
	"Nothing Ear (open)",
	"AirPods van Ofek",
}

-- delay before reacting to device events, lets coreaudio finish registering devices
local SETTLE_DELAY = 1.0

-- locate an input device by exact name match, returns nil if absent
local function findInputByName(name)
	for _, device in ipairs(hs.audiodevice.allInputDevices()) do
		if device:name() == name then
			return device
		end
	end
	return nil
end

-- locate the first output device whose name is in the provided list
local function findFirstMatchingOutput(names)
	-- build a set keyed by name for o(1) lookup, avoids o(n*m) nested loop
	local nameSet = {}
	for _, n in ipairs(names) do
		nameSet[n] = true
	end

	-- walk the current outputs once, return on the first hit
	for _, device in ipairs(hs.audiodevice.allOutputDevices()) do
		if nameSet[device:name()] then
			return device
		end
	end
	return nil
end

-- core decision logic, runs after every device event and once at load
local function checkAndSwitchInput()
	-- look for the insta360 in the current input device list
	local mic = findInputByName(MIC_NAME)

	-- look for the jbl in the current output device list, this is our proxy for "headphones connected"
	local headphones = findFirstMatchingOutput(HEADPHONES_NAMES)

	-- if either is missing the precondition fails, do nothing
	if not mic or not headphones then
		return
	end

	-- skip switching if the mic is already the default, avoids spurious notifications on every event
	local currentInput = hs.audiodevice.defaultInputDevice()
	if currentInput and currentInput:name() == MIC_NAME then
		return
	end

	-- perform the switch, setDefaultInputDevice returns true on success
	local success = mic:setDefaultInputDevice()

	-- notify so you have visible confirmation that automation fired
	if success then
		hs.notify
			.new({
				title = "Audio auto-switch",
				informativeText = "Input set to " .. MIC_NAME,
			})
			:send()
	else
		hs.notify
			.new({
				title = "Audio auto-switch failed",
				informativeText = "Could not set " .. MIC_NAME .. " as input",
			})
			:send()
	end
end

-- debounce handle, multiple device events fire rapidly when a dock connects
local pendingTimer = nil

-- watcher callback, schedules a debounced check rather than running inline
local function onAudioDeviceChange(event)
	-- cancel any previously queued check, restart the debounce window
	if pendingTimer then
		pendingTimer:stop()
	end

	-- queue the actual check after the settle delay
	pendingTimer = hs.timer.doAfter(SETTLE_DELAY, checkAndSwitchInput)
end

-- register the callback with the global audio device watcher
hs.audiodevice.watcher.setCallback(onAudioDeviceChange)

-- start watching, fires on any add or remove of an audio device
hs.audiodevice.watcher.start()

-- run once at load in case both devices are already connected when hammerspoon starts
checkAndSwitchInput()
