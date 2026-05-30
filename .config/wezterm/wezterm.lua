local wezterm = require("wezterm")
local with_keybindings = require("keybindings")
local with_looks = require("looks")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.window_close_confirmation = "NeverPrompt"

with_looks(config)
with_keybindings(config)

-- and finally, return the configuration to wezterm
return config
