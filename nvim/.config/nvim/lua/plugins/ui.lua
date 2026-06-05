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

-- stylua: ignore start
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
				{ icon = " ", key = "c", desc = "Config", action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })", },
				{ icon = "󰚰 ", key = "u", desc = "Update Plugins", action = ":lua vim.pack.update()" },
				{ icon = "󰏗 ", key = "m", desc = "Mason", action = ":Mason" },
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
  { "n",          "<leader>uc",      function() Snacks.picker.colorschemes() end,                            "Colorschemes" },
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
		{ "<leader>d", group = "[d]ebug", icon = { icon = "", color = "red" }, mode = "n" },
		{ "<leader>f", group = "[f]ind", icon = { icon = "󰍉", color = "green" } },
		{ "<leader>F", group = "[F]ormat", icon = { icon = "󰉼", color = "yellow" }, mode = "n" },
		{ "<leader>g", group = "[g]it", icon = { icon = "󰊢", color = "orange" }, mode = { "n", "v" } },
		{ "<leader>h", group = "[h]unks", icon = { icon = "", color = "orange" }, mode = { "n", "v" } },
		{ "<leader>l", group = "[L]int", icon = { icon = "󰁨", color = "yellow" }, mode = "n" },
		{ "<leader>o", group = "[o]pencode", icon = { icon = "󱙺", color = "purple" }, mode = "n" },
		{ "<leader>s", group = "[s]earch", icon = { icon = "󰺯", color = "green" } },
		{ "<leader>S", group = "[S]lime", icon = { icon = "󰒊", color = "cyan" } },
		{ "<leader>t", group = "[t]oggle", icon = { icon = "󰔡", color = "grey" } },
		{ "<leader>T", group = "[T]rouble", icon = { icon = "󰒡", color = "red" }, mode = "n" },
		{ "<leader>u", group = "[u]I", icon = { icon = "", color = "azure" }, mode = "n" },
		{ "<leader>w", group = "[w]orkspace", icon = { icon = "󰒓", color = "blue" }, mode = "n" },
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

-- stylua: ignore start
local todo_maps = {
	---@diagnostic disable-next-line: undefined-field
  { "<leader>st", function() Snacks.picker.todo_comments() end,                                          "Todo" },
	---@diagnostic disable-next-line: undefined-field
  { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, "Todo/Fix/Fixme",
  },
}
-- stylua: ignore end

for _, map in ipairs(todo_maps) do
	vim.keymap.set("n", map[1], map[2], { desc = map[3] })
end

-- INFO: Trouble
vim.pack.add({ "https://github.com/folke/trouble.nvim" }) -- provide diagnostics in quickfix list

require("trouble").setup()

local trouble_maps = {
	{ "<leader>Tx", "diagnostics toggle", "Diagnostics (Trouble)" },
	{ "<leader>TX", "diagnostics toggle filter.buf=0", "Buffer Diagnostics (Trouble)" },
	{ "<leader>Ts", "symbols toggle focus=false", "Symbols (Trouble)" },
	{ "<leader>Tl", "lsp toggle focus=false win.position=right", "LSP Definitions / references / ..." },
	{ "<leader>TL", "loclist toggle", "Location List (Trouble)" },
	{ "<leader>TQ", "qflist toggle", "Quickfix List (Trouble)" },
}

for _, map in ipairs(trouble_maps) do
	vim.keymap.set("n", map[1], "<cmd>Trouble " .. map[2] .. "<cr>", { desc = map[3] })
end

-- INFO: Markdown preview
vim.pack.add({ "https://github.com/iamcco/markdown-preview.nvim" }) -- Provide markdown preview

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		if vim.fn.exists("*mkdp#util#install") == 1 then
			vim.fn["mkdp#util#install"]()
		end
	end,
})

vim.g.mkdp_filetypes = { "markdown" } -- Enable it only for markdown files
