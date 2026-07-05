-- INFO: Lazydev (must be setup before LSP to properly hook into lua_ls)
vim.pack.add({ "https://github.com/folke/lazydev.nvim" }) -- improves lua_ls completion and types for Neovim's API

require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } }, -- adds vim.uv types
	},
})

-- INFO: Treesitter
vim.pack.add({ -- syntax highlighting and parsing
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		build = function()
			require("nvim-treesitter.install").update({ with_sync = true }) -- So it runs :TSUpdate when I update the plugin
		end,
	},
})

require("nvim-treesitter.config").setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
	sync_install = false, -- async install to avoid blocking startup
	ensure_installed = {
		"lua",
		"c",
		"html",
		"luadoc",
		"markdown",
		"vim",
		"vimdoc",
		"bash",
	},
	auto_install = true, -- auto-install parser when opening an unrecognized filetype
	highlight = { enable = true },
})

-- INFO: LSP and respective tooling
local lsp_servers = {
	lua_ls = {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT", -- tells lua_ls we're using Neovim's Lua runtime (LuaJIT)
				},
				diagnostics = {
					globals = { "vim" }, -- prevents "undefined" warnings for Neovim API
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("lua", true), -- exposes Neovim runtime Lua files to the LSP
					checkThirdParty = false,                         -- disables prompts/config suggestions from external libraries
				},
				telemetry = {
					enable = false, -- disables data collection from lua_ls
				},
			},
		},
	},
	clangd = {
		filetypes = { "c", "cpp", "h", "hpp", "objc", "objcpp", "cuda", "proto" }, -- extend defaults to include headers, CUDA, and proto
	},
	bashls = { filetypes = { "bash", "sh", "zsh" } },                          -- extend defaults to include zsh
	pyright = {},
	markdown_oxide = {},
	yamlls = {},
	html = { filetypes = { "html", "templ", "htmlangular" } }, -- extend defaults to include Templ and Angular templates
	tailwindcss = {},
	ts_ls = {},
}

vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",                    -- default configs for 100+ LSP servers
	"https://github.com/mason-org/mason.nvim",                     -- package manager for LSP servers, linters, and formatters
	"https://github.com/mason-org/mason-lspconfig.nvim",           -- bridge between Mason and lspconfig
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", -- auto-installs all servers in lsp_servers on startup
}, { confirm = false })

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = vim.tbl_keys(lsp_servers), -- auto-install every server defined above
})

for server, config in pairs(lsp_servers) do
	vim.lsp.config(server, config)
end
vim.lsp.enable(vim.tbl_keys(lsp_servers)) -- activate all configured servers

-- INFO: Linting
vim.pack.add({
	"https://github.com/mfussenegger/nvim-lint",  -- runs linters and reports results via vim.diagnostic
	"https://github.com/rshkarin/mason-nvim-lint", -- bridge between Mason and nvim-lint (auto-installs linters)
})

require("mason-nvim-lint").setup({
	ensure_installed = { "eslint_d", "pylint", "shellcheck", "selene" }, -- auto-install these linters via Mason
})

local lint = require("lint") ---@type table
lint.linters_by_ft = {
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	python = { "ruff" },
	bash = { "shellcheck" },
	lua = { "selene" },
}

local lint_enabled = false                                 -- linting state flag
local lint_ns = vim.api.nvim_create_namespace("nvim-lint") -- gets namespace for linting diagnostics
local group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = group,
	callback = function()
		if lint_enabled then
			lint.try_lint()
		end
	end,
})

vim.keymap.set("n", "<leader>tl", function() -- toggles linting
	lint_enabled = not lint_enabled

	if lint_enabled then
		vim.notify("Linting enabled")
		lint.try_lint()
	else
		vim.notify("Linting disabled")
		vim.diagnostic.reset(lint_ns, 0) -- clear linting diagnostics
	end
end, { desc = "Toggle linting" })
