-- Personal window behavior, loaded after Omarchy's window rules.

hl.config({
  misc = {
    middle_click_paste = false,
    enable_swallow = true,
    swallow_regex = "^(com\\.mitchellh\\.ghostty|foot|kitty|Alacritty)$",
  },
})

-- Floating windows remember the size they were last given.
o.window({ float = true }, { persistent_size = true })

o.window("^(org\\.pulseaudio\\.pavucontrol|blueman-manager|nm-connection-editor)$", { tag = "+floating-window" })
o.window({ class = ".*dialog.*" }, { float = true })
o.window({ title = ".*dialog.*" }, { float = true })
