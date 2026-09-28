-- Personal keybinding overrides, loaded after Omarchy's bindings.
-- See current bindings with: omarchy menu keybindings --print

-- Super+Q closes too (Omarchy's Super+W stays).
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Super+L locks; workspace layout toggle moves to Super+Shift+L.
hl.unbind("SUPER + L")
o.bind("SUPER + L", "Lock system", "omarchy-system-lock")
o.bind("SUPER + SHIFT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Chromium profiles. The default browser is chromium-work.desktop, so Omarchy's
-- Super+Shift+B / Return / Alt+B already open Work.
local WORK, PERSONAL = "--profile-directory=Default", "--profile-directory=Personal"
o.bind("SUPER + SHIFT + CTRL + B", "Browser (personal)",
  o.launch(os.getenv("HOME") .. "/.local/lib/chromium-profiles/personal/chromium"))

local function webapp(keys, description, url, profile, focus)
  hl.unbind(keys)
  local cmd = focus and o.launch_webapp_sole(description, url) or o.launch_webapp(url)
  o.bind(keys, description, cmd .. " " .. profile)
end

if o.preinstalled_bindings_enabled() then
  webapp("SUPER + SHIFT + C", "Calendar", "https://calendar.google.com/", WORK)
  webapp("SUPER + SHIFT + E", "Email", "https://mail.google.com/", WORK)
  webapp("SUPER + SHIFT + ALT + E", "New email", "https://mail.google.com/mail/?view=cm&fs=1", WORK)
  webapp("SUPER + SHIFT + Y", "YouTube", "https://youtube.com/", PERSONAL)
  webapp("SUPER + SHIFT + ALT + G", "WhatsApp", "https://web.whatsapp.com/", PERSONAL, true)
  webapp("SUPER + SHIFT + CTRL + G", "Google Messages", "https://messages.google.com/web/conversations", PERSONAL, true)
  webapp("SUPER + SHIFT + P", "Google Photos", "https://photos.google.com/", PERSONAL, true)
  webapp("SUPER + SHIFT + S", "Google Maps", "https://maps.google.com/", PERSONAL, true)
  webapp("SUPER + SHIFT + X", "X", "https://x.com/", PERSONAL)
  webapp("SUPER + SHIFT + ALT + X", "X Post", "https://x.com/compose/post", PERSONAL)
end
