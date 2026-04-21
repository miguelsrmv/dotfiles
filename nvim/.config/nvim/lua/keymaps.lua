-- [[ Keymaps ]]
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear search highlights by pressing <Esc> in normal mode
vim.keymap.set("n", "<leader>wh", ":split<CR>", { desc = "Split window horizontally" }) -- Split the current window horizontally
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { desc = "Split window vertically" }) -- Split the current window vertically

vim.api.nvim_create_autocmd("TextYankPost", { -- Autocommand: Briefly flash-highlight the yanked region
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
