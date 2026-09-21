-- Theme follows `dot theme`: kanagawa.nvim for the Kanagawa theme (it is far better
-- than any generated palette), base16 from Noctalia's generated colours otherwise.
-- `dot theme` sends SIGUSR1 after switching; the autocmd below re-applies live.

local function theme_name()
  local f = io.open((os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/dotfiles/theme")
  if not f then return "kanagawa" end
  local n = f:read("*l"); f:close()
  return (n and #n > 0) and n or "kanagawa"
end

local function apply()
  if theme_name() == "kanagawa" then
    vim.cmd.colorscheme("kanagawa-wave")
    return
  end
  package.loaded["noctalia"] = nil
  local ok, noct = pcall(require, "noctalia")
  if ok and noct.palette then
    require("base16-colorscheme").setup(noct.palette)
    vim.g.colors_name = "noctalia"
    -- keep the terminal's transparency
    for _, g in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "LineNr", "EndOfBuffer" }) do
      vim.api.nvim_set_hl(0, g, { bg = "none" })
    end
  else
    vim.cmd.colorscheme("kanagawa-wave")
  end
end

return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      theme = "wave",
      transparent = true,
      dimInactive = false,
      terminalColors = true,
      colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
      overrides = function(colors)
        local t = colors.theme
        return {
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },
          TelescopeNormal = { bg = "none" },
          TelescopeBorder = { bg = "none" },
          Pmenu = { fg = t.ui.shade0, bg = t.ui.bg_p1, blend = 5 },
          PmenuSel = { fg = "NONE", bg = t.ui.bg_p2 },
          PmenuSbar = { bg = t.ui.bg_m1 },
          PmenuThumb = { bg = t.ui.bg_p2 },
        }
      end,
    },
  },
  { "RRethy/base16-nvim", lazy = false, priority = 999 },
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = apply
      vim.api.nvim_create_autocmd("Signal", { pattern = "SIGUSR1", callback = apply })
    end,
  },
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
}
