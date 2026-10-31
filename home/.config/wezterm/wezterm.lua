local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 12.0
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.92
config.window_decorations = "RESIZE"
config.initial_rows = 48
config.initial_cols = 160

return config

