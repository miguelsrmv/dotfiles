-- INFO: Blink
vim.pack.add({
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",
}, { confirm = false }) -- Completion engine

require("blink.cmp").build():pwait()

require("blink.cmp").setup({
	completion = {
		documentation = {
			auto_show = true,
		},
	},

	keymap = {
		["<C-n>"] = { "select_next", "fallback_to_mappings" },
		["<C-p>"] = { "select_prev", "fallback_to_mappings" },
		["<C-y>"] = { "select_and_accept", "fallback" },
		["<C-e>"] = { "cancel", "fallback" },
		["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
		["<CR>"] = { "select_and_accept", "fallback" },
		-- ["<Esc>"] = { "cancel", "hide_documentation", "fallback" }, NOTE: Removed due to interference with exiting Insert Mode
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
	},

	sources = {
		default = { "lazydev", "lsp", "buffer", "snippets", "path" },
		providers = {
			lazydev = { -- Adds lazydev as a source for completion
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100, -- show lazydev completions before lsp
			},
		},
	},
})
