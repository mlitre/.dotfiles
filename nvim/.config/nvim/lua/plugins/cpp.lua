-- clangd tuned for CMake projects. Needs compile_commands.json
-- at the project root or in build/ (alias `cmb` + `ccc` from zsh does both).
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
            "--function-arg-placeholders=0",
            "--fallback-style=llvm",
            "--query-driver=/usr/bin/*g++,/usr/bin/*gcc,/usr/bin/clang++",
            "--compile-commands-dir=build",
          },
          init_options = { usePlaceholders = false, clangdFileStatus = true },
        },
      },
    },
  },
  {
    "p00f/clangd_extensions.nvim",
    opts = { inlay_hints = { inline = false }, ast = { role_icons = {}, kind_icons = {} } },
  },
}
