require("telescope").setup {
    defaults = {
        file_ignore_patterns = {
            ".cache",
            "src/release",
            "compile_commands.json",
            ".log"
        },
    },
	pickers = {
		find_files = {
			-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
			find_command = {
                "rg",
                "--files",
                "--hidden",
                "--glob",
                "!**/.git/*",
                "--no-ignore"
            },
		},
	},
}
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

