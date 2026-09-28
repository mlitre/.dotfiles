-- Hyprland default apps
TERMINAL     = "ghostty"
FILE_MANAGER = "dolphin"
BROWSER      = "firefox"
EDITOR       = "ghostty -e nvim"
CALCULATOR   = "gnome-calculator"

-- Monitors: defaults are the laptop panel alone. Per-machine values
-- (dock monitor name, scale) live in config/local.lua (git-ignored,
-- see config/local.lua.example). Run `hyprctl monitors` for the names.
MONITOR1 = "eDP-1"
MONITOR2 = ""
MONITOR3 = ""

-- Workspaces per monitor (max 10)
NUM_WPM = 3

local ok, localcfg = pcall(require, "config.local")
if ok and type(localcfg) == "table" then
    for k, v in pairs(localcfg) do _G[k] = v end
end
PRIMARY_MONITOR = PRIMARY_MONITOR or MONITOR1
