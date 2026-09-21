-- CachyOS Hyprland Configuration

require("config.animations")
require("config.autostart")
require("config.colors")
require("config.decorations")
require("config.variables")
require("config.environment")
require("config.inputs")
require("config.binds")
require("config.misc")
require("config.monitors")
require("config.windowrules")
require("config.workspaces")

-- Noctalia writes ~/.config/hypr/noctalia.lua from its templates. It does not
-- exist until the first render, so on a fresh install a bare require aborts the
-- whole config. Load it optionally, same as config.local in variables.lua.
local ok, noctalia = pcall(require, "noctalia")
if ok then noctalia.apply_theme() end
