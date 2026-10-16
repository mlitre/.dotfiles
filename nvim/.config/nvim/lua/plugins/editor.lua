return {
  -- carried over from the old config
  { "mbbill/undotree", keys = { { "<leader>u", vim.cmd.UndotreeToggle, desc = "Undotree" } } },
  { "tpope/vim-fugitive", cmd = { "Git", "G" }, keys = { { "<leader>gs", vim.cmd.Git, desc = "Fugitive" } } },
  { "folke/zen-mode.nvim", cmd = "ZenMode", keys = { { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Zen mode" } }, opts = { window = { width = 90 } } },
  {
    "laytan/cloak.nvim",
    event = "VeryLazy",
    opts = {
      patterns = { { file_pattern = { ".env*", "wrangler.toml", ".dev.vars", "*.secrets" }, cloak_pattern = "=.+" } },
    },
  },
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "auto" } } },
  -- `nvim .` opens netrw instead of the Snacks explorer; <leader>e still toggles it
  { "folke/snacks.nvim", opts = { explorer = { replace_netrw = false } } },
}
