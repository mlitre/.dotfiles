-- Monitors https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Layout comes from MONITORS in config/local.lua when present; otherwise the
-- laptop panel at preferred mode. Any monitor not listed is still auto-placed.
if type(MONITORS) == "table" then
    for _, m in ipairs(MONITORS) do hl.monitor(m) end
else
    hl.monitor({ output = MONITOR1, mode = "preferred", position = "auto", scale = "auto" })
end
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" }) -- catch-all for hot-plugged displays
