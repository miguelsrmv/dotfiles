-- INFO: Opencode integration
vim.pack.add({ "https://github.com/nickjvandyke/opencode.nvim" })

vim.g.opencode_opts = {}
vim.o.autoread = true

vim.keymap.set({ "n", "x" }, "<leader>oc", function()
	require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode…" })

vim.keymap.set({ "n", "x" }, "<leader>oo", function()
	require("opencode").select()
end, { desc = "Select opencode…" })

vim.keymap.set({ "n", "x" }, "<leader>or", function()
	return require("opencode").operator("@this ")
end, { desc = "Add range to opencode", expr = true })

vim.keymap.set("n", "<leader>ol", function()
	return require("opencode").operator("@this ") .. "_"
end, { desc = "Add line to opencode", expr = true })
