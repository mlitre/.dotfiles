-- Workspace rules https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
hl.workspace_rule({ workspace = "name:gaming", monitor = PRIMARY_MONITOR, default = true })
for i = 1, NUM_WPM do
    hl.workspace_rule({ workspace = tostring(i), monitor = MONITOR1, default = true, persistent = true })
end
if MONITOR2 ~= "" then
    for i = NUM_WPM + 1, NUM_WPM * 2 do
        hl.workspace_rule({ workspace = tostring(i), monitor = MONITOR2, default = true, persistent = true })
    end
end
