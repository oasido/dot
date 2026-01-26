local wezterm = require("wezterm")

local function with_looks(config, theme)
	config.colors = theme.colors()
	config.window_frame = theme.window_frame()
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
	})

	config.native_macos_fullscreen_mode = true

	config.font_size = 21.0
end

return with_looks
