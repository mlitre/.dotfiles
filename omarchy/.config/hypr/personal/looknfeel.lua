-- Personal look'n'feel overrides, loaded after Omarchy's defaults.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
  general = {
    resize_on_border = true,
  },
  decoration = {
    rounding = 10,
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
      special = true,
    },
  },
})

-- Window transparency (active inactive). Terminals set their own in their config.
o.window({ tag = "terminal" }, { tag = "-default-opacity", opacity = "1 1" })
o.window({ tag = "default-opacity" }, { opacity = "0.85 0.75" })
