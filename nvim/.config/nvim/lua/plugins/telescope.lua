-- Old telescope settings, minus `--no-ignore` (respect .gitignore, still show dotfiles)
return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = { "%.cache/", "src/release/", "compile_commands%.json", "%.log$", "^build/", "^target/" },
      },
      pickers = {
        find_files = { find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } },
      },
    },
    keys = {
      { "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find files (old habit)" },
      { "<C-p>", "<cmd>Telescope git_files<cr>", desc = "Git files" },
      { "<leader>ps", function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end, desc = "Grep prompt" },
    },
  },
}
