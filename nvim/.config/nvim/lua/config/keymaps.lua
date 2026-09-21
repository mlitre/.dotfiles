-- Personal keymaps ported from the old remap.lua. LazyVim's own maps stay.
-- Moved because LazyVim already uses the prefix:
--   <leader>s  (search)        -> substitute word is <leader>rw
--   <leader>x  (diagnostics)   -> chmod +x is <leader>cx
--   <leader>f  (find/file)     -> format is LazyVim's <leader>cf
--   <leader>pv (netrw)         -> LazyVim explorer <leader>e / <leader>fe
--   <C-h/t/n/s> harpoon slots  -> harpoon2 extra: <leader>H add, <leader>h menu, <leader>1..5
local map = vim.keymap.set

-- move selected lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- keep cursor where it is / centred
map("n", "J", "mzJ`z", { desc = "Join line (keep cursor)" })
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- registers
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to black hole" })

-- this is going to get me cancelled
map("i", "<C-c>", "<Esc>")
map("n", "Q", "<nop>")

-- quickfix / loclist (LazyVim has ]q [q too; keep the old ones)
map("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
map("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })
map("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next loclist" })
map("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Prev loclist" })

map("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
map("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x current file" })
map("n", "<leader><leader>", function() vim.cmd("so") end, { desc = "Source current file" })
