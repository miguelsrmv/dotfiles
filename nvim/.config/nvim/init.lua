---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global

-- [[ Options ]]
-- Leader keys (must be set before plugins load)
vim.g.mapleader = " " -- Set <space> as the global leader key
vim.g.maplocalleader = " " -- Set <space> as the local leader key (buffer-local mappings)

-- Nerd fonts
vim.g.have_nerd_font = true -- Tell Neovim a Nerd Font is installed (enables icon/glyph rendering)

-- Colors
vim.opt.termguicolors = true -- Use 24-bit RGB colors instead of the terminal's 256-color palette

-- Line numbers
vim.opt.number = true -- Show absolute line number on the current line
vim.opt.relativenumber = true -- Show relative line numbers on all other lines (useful for jump commands)
vim.opt.cursorline = true -- Highlight the entire line the cursor is on

-- Indentation
vim.opt.tabstop = 2 -- A <Tab> character visually occupies 2 spaces
vim.opt.shiftwidth = 2 -- Each indentation level (>> / <<) uses 2 spaces
vim.opt.expandtab = true -- Insert spaces instead of a real tab character when pressing <Tab>

-- Searching
vim.opt.ignorecase = true -- Ignore case when searching...
vim.opt.smartcase = true -- ...unless the search term contains an uppercase letter or \C flag
vim.opt.hlsearch = true -- Highlight all search matches; press <Esc> in normal mode to clear
vim.opt.inccommand = "split" -- Preview :substitute replacements live in a split as you type
vim.opt.grepprg = "rg --vimgrep" -- Use ripgrep for :grep instead of the slow default grep
vim.opt.grepformat = "%f:%l:%c:%m" -- Matches ripgrep's output format

-- Splits
vim.opt.splitright = true -- Open vertical splits to the right of the current window
vim.opt.splitbelow = true -- Open horizontal splits below the current window
vim.opt.splitkeep = "screen" -- Prevents the buffer from jumping when opening splits

-- Scrolling
vim.opt.scrolloff = 10 -- Always keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Always keep 8 columns left/right of cursor

-- Wrapping
vim.opt.wrap = false -- Disable line wrapping (scroll horizontally instead)
vim.opt.breakindent = true -- If wrap is ever enabled, wrapped lines continue at the same indentation level
vim.opt.textwidth = 80 -- Hard-wrap lines at 80 characters when inserting text

-- Whitespace display
vim.opt.list = true -- Enable rendering of invisible characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- Tabs as », trailing spaces as ·, non-breaking spaces as ␣

-- Undo
vim.opt.undofile = true -- Persist undo history across sessions (undo even after closing a file)
vim.opt.undolevels = 10000 -- Maximum number of undo steps to keep

-- Timing
vim.opt.updatetime = 250 -- Write swap file and trigger CursorHold faster (250ms vs 4s default)
vim.opt.timeoutlen = 300 -- Shorten wait time for a key sequence to complete (affects which-key popup)
vim.o.ttimeoutlen = 10 -- Shorten wait time for terminal key codes (reduces ESC key delay)

-- Misc
vim.opt.mouse = "a" -- Enable mouse support in all modes (clicking, scrolling, resizing splits)
vim.opt.showmode = false -- Hide the mode indicator (-- INSERT --, etc.) since the statusline shows it
vim.opt.clipboard = "unnamedplus" -- Share system clipboard with Neovim (yank/paste works across apps)
vim.opt.signcolumn = "yes" -- Always show the sign column (prevents buffer shifting when diagnostics appear)
vim.opt.autowrite = true -- Auto-save when switching buffers or running commands

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ", -- Error icon in the sign column
			[vim.diagnostic.severity.WARN] = " ", -- Warning icon in the sign column
			[vim.diagnostic.severity.INFO] = " ", -- Info icon in the sign column
			[vim.diagnostic.severity.HINT] = " ", -- Hint icon in the sign column
		},
	},
	virtual_text = true, -- Show diagnostic messages inline at the end of the affected line
})

-- [[ Keybinds ]]
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

-- [[  Plugins ]]
-- INFO: Colorschemes
-- TODO: Check if all work or if setup is needed!
vim.pack.add({
	"https://github.com/EdenEast/nightfox.nvim",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/catppuccin/nvim",
	"https://github.com/gbprod/nord.nvim",
	"https://github.com/neanias/everforest-nvim",
	"https://github.com/ellisonleao/gruvbox.nvim",
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/rose-pine/neovim",
	"https://github.com/olimorris/onedarkpro.nvim",
	"https://github.com/mofiqul/dracula.nvim",
	"https://github.com/tahayvr/matteblack.nvim",
	"https://github.com/ribru17/bamboo.nvim",
	"https://github.com/loctvl842/monokai-pro.nvim",
})

vim.cmd.colorscheme("tokyonight-night") -- Sets colorscheme

-- INFO: Treesitter
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }, -- Treesitter for formatting and syntax highlighting
})

require("nvim-treesitter.install").update({ "all" }) -- Equivalent to :TSUpdate
require("nvim-treesitter.config").setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
	sync_install = true, -- install parsers synchronously
	modules = {},
	ignore_install = {}, -- don't exclude parsers from install
	ensure_installed = { -- define parsers to always have installed
		"lua",
		"c",
		"html",
		"luadoc",
		"markdown",
		"vim",
		"vimdoc",
		"bash",
	},
	auto_install = true, -- autoinstall languages that are not installed yet
	highlight = {
		enable = true, -- enable treesitter syntax highlighting
	},
})

-- INFO: LSP server installation and configuration
local lsp_servers = {
	lua_ls = {
		settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) } } }, -- Expose Neovim runtime files to lua_ls for better completion
	},
	clangd = {
		filetypes = { "c", "cpp", "h", "hpp", "objc", "objcpp", "cuda", "proto" }, -- Extend defaults to include headers, CUDA, and proto files
	},
	bashls = {
		filetypes = { "bash", "sh", "zsh" }, -- Extend defaults to include zsh
	},
	pyright = {},
	markdown_oxide = {},
	yamlls = {},
	html = {
		filetypes = { "html", "templ", "htmlangular" }, -- Extend defaults to include Templ and Angular templates
	},
	tailwindcss = {},
	ts_ls = {},
}

vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig", -- Default configs for 100+ LSP servers
	"https://github.com/mason-org/mason.nvim", -- Package manager for LSP servers, linters, and formatters
	"https://github.com/mason-org/mason-lspconfig.nvim", -- Bridge between Mason and lspconfig (auto-configures installed servers)
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", -- Ensures all servers in lsp_servers{} are auto-installed on startup
}, { confirm = false })

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = vim.tbl_keys(lsp_servers), -- Auto-install every server defined in the table above
})

for server, config in pairs(lsp_servers) do -- Register each LSP server with its settings
	vim.lsp.config(server, config)
end

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
		python = { "black" },
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

-- INFO: Blink
vim.pack.add({ "https://github.com/saghen/blink.cmp" }, { confirm = false }) -- Completion engine

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

	fuzzy = {
		implementation = "lua",
	},
})

-- INFO: Git
vim.pack.add({
	"https://github.com/lewis6991/gitsigns.nvim", -- Shows git diff markers (added/changed/removed lines) in the sign column and provides hunk navigation & staging
	"https://github.com/tpope/vim-fugitive", -- Full Git integration inside Neovim
})

require("gitsigns").setup({
	signs = {
		add = { text = "+" }, ---@diagnostic disable-line: missing-fields
		change = { text = "~" }, ---@diagnostic disable-line: missing-fields
		delete = { text = "_" }, ---@diagnostic disable-line: missing-fields
		topdelete = { text = "‾" }, ---@diagnostic disable-line: missing-fields
		changedelete = { text = "~" }, ---@diagnostic disable-line: missing-fields
	},
	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation (kept as-is due to diff check logic)
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, { desc = "Next git change" })
		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, { desc = "Prev git change" })

		-- Visual (kept as-is due to line range)
		map("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Stage hunk" })
		map("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Reset hunk" })

		-- Normal mode actions
		local normal_maps = {
			{ "<leader>hs", gs.stage_hunk, "Stage hunk" },
			{ "<leader>hr", gs.reset_hunk, "Reset hunk" },
			{ "<leader>hS", gs.stage_buffer, "Stage buffer" },
			{ "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk" },
			{ "<leader>hR", gs.reset_buffer, "Reset buffer" },
			{ "<leader>hp", gs.preview_hunk, "Preview hunk" },
			{ "<leader>hb", gs.blame_line, "Blame line" },
			{ "<leader>hd", gs.diffthis, "Diff against index" },
			{
				"<leader>hD",
				function()
					gs.diffthis("@")
				end,
				"Diff against last commit",
			},
			{ "<leader>tb", gs.toggle_current_line_blame, "Toggle blame line" },
			{ "<leader>tD", gs.preview_hunk_inline, "Toggle show deleted" },
		}

		for _, m in ipairs(normal_maps) do
			map("n", m[1], m[2], { desc = m[3] })
		end
	end,
})

-- INFO: Vim-Tmux Navigator
vim.pack.add({ "https://github.com/christoomey/vim-tmux-navigator" }) -- Allows for tmux / nvim integration

local tmux_maps = {
	{ "<C-h>", "Left", "Navigate left" },
	{ "<C-j>", "Down", "Navigate down" },
	{ "<C-k>", "Up", "Navigate up" },
	{ "<C-l>", "Right", "Navigate right" },
	{ "<C-\\>", "Previous", "Navigate previous" },
}

for _, map in ipairs(tmux_maps) do
	vim.keymap.set("n", map[1], "<cmd>TmuxNavigate" .. map[2] .. "<cr>", { desc = map[3] })
end

-- INFO: Mini
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" }) -- Set of utilities

require("mini.ai").setup() -- Extends text objects (e.g. select inside function, class, etc.)
require("mini.surround").setup() -- Add/change/delete surrounding characters (brackets, quotes, tags)
require("mini.pairs").setup() -- Auto-close brackets, quotes, and other pairs
require("mini.icons").setup() -- Provides icons for other plugins (replaces nvim-web-devicons)
require("mini.statusline").setup() -- Provides easy statusline

-- INFO: Snacks
vim.pack.add({ "https://github.com/folke/snacks.nvim" }) -- Set of utilities

require("snacks").setup({
	bigfile = { enabled = true }, -- Disables heavy features for large files to keep Neovim fast
	indent = { enabled = true }, -- Shows indent guides
	explorer = { enabled = true, hidden = true }, -- File explorer (shows hidden files)
	input = { enabled = true }, -- Replaces vim.ui.input with a nicer prompt
	notifier = { enabled = true, timeout = 3000 }, -- Replaces vim.notify with a popup notification system
	quickfile = { enabled = true }, -- Renders files faster before plugins finish loading
	scope = { enabled = true }, -- Detects the current code scope for smarter indent guides
	scroll = { enabled = true }, -- Smooth scrolling
	statuscolumn = { enabled = true }, -- Custom status column (line numbers, signs, folds)
	words = { enabled = true }, -- Highlights and navigates all occurrences of the word under cursor
	dashboard = { -- Provides welcoming dashboard
		enabled = true,
		preset = {
			keys = {
				{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
				{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
				{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
				{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
				{
					icon = " ",
					key = "c",
					desc = "Config",
					action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })",
				},
				{ icon = "󰚰 ", key = "u", desc = "Update Plugins", action = ":lua vim.pack.update()" },
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
		},
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 2 },
			{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 2 },
			{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
		},
	},
	styles = {
		notification = {},
	},
})

-- stylua: ignore start
local snacks_maps = {
  -- Top Pickers & Explorer
  { "n",          "<leader><space>", function() Snacks.picker.smart() end,                                   "Smart Find Files" },
  { "n",          "<leader>,",       function() Snacks.picker.buffers() end,                                 "Buffers" },
  { "n",          "<leader>/",       function() Snacks.picker.grep() end,                                    "Grep" },
  { "n",          "<leader>:",       function() Snacks.picker.command_history() end,                         "Command History" },
  { "n",          "<leader>n",       function() Snacks.picker.notifications() end,                           "Notification History" },
  { "n",          "<leader>e",       function() Snacks.explorer() end,                                       "File Explorer" },
  -- Find
  { "n",          "<leader>fb",      function() Snacks.picker.buffers() end,                                 "Buffers" },
  { "n",          "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, "Find Config File" },
  { "n",          "<leader>ff",      function() Snacks.picker.files() end,                                   "Find Files" },
  { "n",          "<leader>fg",      function() Snacks.picker.git_files() end,                               "Find Git Files" },
  { "n",          "<leader>fp",      function() Snacks.picker.projects() end,                                "Projects" },
  { "n",          "<leader>fr",      function() Snacks.picker.recent() end,                                  "Recent" },
  -- Git
  { "n",          "<leader>gb",      function() Snacks.picker.git_branches() end,                            "Git Branches" },
  { "n",          "<leader>gl",      function() Snacks.picker.git_log() end,                                 "Git Log" },
  { "n",          "<leader>gL",      function() Snacks.picker.git_log_line() end,                            "Git Log Line" },
  { "n",          "<leader>gs",      function() Snacks.picker.git_status() end,                              "Git Status" },
  { "n",          "<leader>gS",      function() Snacks.picker.git_stash() end,                               "Git Stash" },
  { "n",          "<leader>gd",      function() Snacks.picker.git_diff() end,                                "Git Diff (Hunks)" },
  { "n",          "<leader>gf",      function() Snacks.picker.git_log_file() end,                            "Git Log File" },
  -- GitHub
  { "n",          "<leader>gi",      function() Snacks.picker.gh_issue() end,                                "GitHub Issues (open)" },
  { "n",          "<leader>gI",      function() Snacks.picker.gh_issue({ state = "all" }) end,               "GitHub Issues (all)" },
  { "n",          "<leader>gp",      function() Snacks.picker.gh_pr() end,                                   "GitHub Pull Requests (open)" },
  { "n",          "<leader>gP",      function() Snacks.picker.gh_pr({ state = "all" }) end,                  "GitHub Pull Requests (all)" },
  -- Grep
  { "n",          "<leader>sb",      function() Snacks.picker.lines() end,                                   "Buffer Lines" },
  { "n",          "<leader>sB",      function() Snacks.picker.grep_buffers() end,                            "Grep Open Buffers" },
  { "n",          "<leader>sg",      function() Snacks.picker.grep() end,                                    "Grep" },
  { { "n", "x" }, "<leader>sw",      function() Snacks.picker.grep_word() end,                               "Visual selection or word" },
  -- Search
  { "n",          '<leader>s"',      function() Snacks.picker.registers() end,                               "Registers" },
  { "n",          "<leader>s/",      function() Snacks.picker.search_history() end,                          "Search History" },
  { "n",          "<leader>sa",      function() Snacks.picker.autocmds() end,                                "Autocmds" },
  { "n",          "<leader>sc",      function() Snacks.picker.command_history() end,                         "Command History" },
  { "n",          "<leader>sC",      function() Snacks.picker.commands() end,                                "Commands" },
  { "n",          "<leader>sd",      function() Snacks.picker.diagnostics() end,                             "Diagnostics" },
  { "n",          "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                      "Buffer Diagnostics" },
  { "n",          "<leader>sh",      function() Snacks.picker.help() end,                                    "Help Pages" },
  { "n",          "<leader>sH",      function() Snacks.picker.highlights() end,                              "Highlights" },
  { "n",          "<leader>si",      function() Snacks.picker.icons() end,                                   "Icons" },
  { "n",          "<leader>sj",      function() Snacks.picker.jumps() end,                                   "Jumps" },
  { "n",          "<leader>sk",      function() Snacks.picker.keymaps() end,                                 "Keymaps" },
  { "n",          "<leader>sl",      function() Snacks.picker.loclist() end,                                 "Location List" },
  { "n",          "<leader>sm",      function() Snacks.picker.marks() end,                                   "Marks" },
  { "n",          "<leader>sM",      function() Snacks.picker.man() end,                                     "Man Pages" },
  { "n",          "<leader>sq",      function() Snacks.picker.qflist() end,                                  "Quickfix List" },
  { "n",          "<leader>sR",      function() Snacks.picker.resume() end,                                  "Resume" },
  { "n",          "<leader>su",      function() Snacks.picker.undo() end,                                    "Undo History" },
  { "n",          "<leader>C",       function() Snacks.picker.colorschemes() end,                            "Colorschemes" },
  -- LSP
  { "n",          "gd",              function() Snacks.picker.lsp_definitions() end,                         "Goto Definition" },
  { "n",          "gD",              function() Snacks.picker.lsp_declarations() end,                        "Goto Declaration" },
  { "n",          "gr",              function() Snacks.picker.lsp_references() end,                          "References" },
  { "n",          "gI",              function() Snacks.picker.lsp_implementations() end,                     "Goto Implementation" },
  { "n",          "gy",              function() Snacks.picker.lsp_type_definitions() end,                    "Goto Type Definition" },
  { "n",          "gai",             function() Snacks.picker.lsp_incoming_calls() end,                      "Calls Incoming" },
  { "n",          "gao",             function() Snacks.picker.lsp_outgoing_calls() end,                      "Calls Outgoing" },
  { "n",          "<leader>ss",      function() Snacks.picker.lsp_symbols() end,                             "LSP Symbols" },
  { "n",          "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end,                   "LSP Workspace Symbols" },
}
-- stylua: ignore end

for _, map in ipairs(snacks_maps) do
	vim.keymap.set(map[1], map[2], map[3], { desc = map[4] })
end

-- INFO: Which Key
vim.pack.add({ "https://github.com/folke/which-key.nvim" }, { confirm = false }) -- Show keybindings

require("which-key").setup({
	spec = {
		{ "<leader>c", group = "[c]ode symbols", mode = "n" },
		{ "<leader>C", group = "[C]olorscheme", mode = "n" },
		{ "<leader>f", group = "[f]ind", icon = { icon = "", color = "green" } },
		{ "<leader>F", group = "[F]ormat", mode = "n" },
		{ "<leader>g", group = "[g]it", mode = { "n", "v" } },
		{ "<leader>h", group = "[h]unks", mode = { "n", "v" } },
		{ "<leader>s", group = "[s]earch", icon = { icon = "", color = "green" } },
		{ "<leader>t", group = "[t]oggle", mode = "n" },
		{ "<leader>w", group = "[w]orkspace", mode = "n" },
		{ "<leader>x", group = "Diagnostics", mode = "n" },
	},
	win = {
		height = { min = 3, max = 5 },
	},
})

-- INFO: TODO-Comments
vim.pack.add({
	"https://github.com/folke/todo-comments.nvim", -- highlight TODO/INFO/WARN comments
})

require("todo-comments").setup()

-- INFO: Diagnostics
vim.pack.add({ "https://github.com/folke/trouble.nvim" }) -- provide diagnostics in quickfix list

require("trouble").setup()

local trouble_maps = {
	{ "<leader>xx", "diagnostics toggle", "Diagnostics (Trouble)" },
	{ "<leader>xX", "diagnostics toggle filter.buf=0", "Buffer Diagnostics (Trouble)" },
	{ "<leader>cs", "symbols toggle focus=false", "Symbols (Trouble)" },
	{ "<leader>cl", "lsp toggle focus=false win.position=right", "LSP Definitions / references / ..." },
	{ "<leader>xL", "loclist toggle", "Location List (Trouble)" },
	{ "<leader>xQ", "qflist toggle", "Quickfix List (Trouble)" },
}

for _, map in ipairs(trouble_maps) do
	vim.keymap.set("n", map[1], "<cmd>Trouble " .. map[2] .. "<cr>", { desc = map[3] })
end
