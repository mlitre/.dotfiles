-- Personal keybinding overrides, loaded after Omarchy's bindings.
-- See current bindings with: omarchy menu keybindings --print

-- Super+Q closes too (Omarchy's Super+W stays).
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Super+L locks; workspace layout toggle moves to Super+Shift+L.
hl.unbind("SUPER + L")
o.bind("SUPER + L", "Lock system", "omarchy-system-lock")
o.bind("SUPER + SHIFT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
