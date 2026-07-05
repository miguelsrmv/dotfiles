-- INFO: Conform
vim.pack.add({ "https://github.com/stevearc/conform.nvim" }, { confirm = false }) -- Autoformatting

require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable_filetypes = {} -- Add filetypes here to skip format-on-save for them (e.g. { c = true })
		if disable_filetypes[vim.bo[bufnr].filetype] then
			return nil
		else
			return { timeout_ms = 1000, lsp_format = "fallback" }
		end
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		typescript = { "prettier" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		json = { "prettier" },
		html = { "prettier" },
		htmlangular = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		yaml = { "prettier" },
		python = { "ruff_format" },
	},
	formatters = {
		["clang-format"] = {
			prepend_args = { "-style", "{BasedOnStyle: Google, UseTab: Always, IndentWidth: 4, TabWidth: 4}" },
		},
	},
})

vim.keymap.set("", "<leader>F", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

-- INFO: Guess-indent
vim.pack.add({ "https://www.github.com/nmac427/guess-indent.nvim" }) -- Guesses indentation

require("guess-indent").setup()
