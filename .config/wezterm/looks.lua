local wezterm = require("wezterm")
local theme = require("lua/kanagawa")
-- local theme = require("lua/rose-pine").main

local function with_looks(config)
	config.colors = type(theme.colors) == "function" and theme.colors() or theme.colors
	config.force_reverse_video_cursor = theme.force_reverse_video_cursor
	config.hide_tab_bar_if_only_one_tab = true
	config.window_decorations = "RESIZE"
	config.window_padding = {
		left = 8,
		right = 8,
		top = 8,
		bottom = 8,
	}

	config.bidi_enabled = true

	config.line_height = 1.2

	config.font = wezterm.font({
		family = "IosevkaTerm Nerd Font Mono",
		-- family = "JetBrainsMono Nerd Font",
	})

	config.native_macos_fullscreen_mode = true

	config.font_size = 19.0
end

return with_looks
