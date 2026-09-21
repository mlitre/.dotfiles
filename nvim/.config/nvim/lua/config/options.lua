-- Options carried over from the old set.lua where they differ from LazyVim.
local opt = vim.opt

opt.guicursor = ""              -- fat cursor everywhere
opt.tabstop = 4                 -- C++/Rust: 4 spaces (LazyVim defaults to 2)
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.wrap = false
opt.scrolloff = 8
opt.colorcolumn = "80"
opt.hlsearch = false
opt.swapfile = false
opt.isfname:append("@-@")
-- undofile/relativenumber/termguicolors/signcolumn/updatetime already on in LazyVim

vim.g.lazyvim_picker = "telescope"
vim.g.autoformat = false        -- <leader>cf formats on demand; clang-format rules vary per repo
