-- INFO: DAP (Debugger)
vim.pack.add({
	"https://github.com/mfussenegger/nvim-dap", -- core debugger engine, implements the Debug Adapter Protocol
	"https://github.com/rcarriga/nvim-dap-ui", -- UI panels for variables, stack, breakpoints, console
	"https://github.com/nvim-neotest/nvim-nio", -- required dependency for nvim-dap-ui (async IO library)
	"https://github.com/jay-babu/mason-nvim-dap.nvim", -- bridge between Mason and nvim-dap (auto-installs debug adapters)
	"https://github.com/mfussenegger/nvim-dap-python", -- Python debug adapter config
})

local dap = require("dap")
local dapui = require("dapui")

-- Auto-install debug adapters via Mason
require("mason-nvim-dap").setup({
	automatic_installation = true, -- auto-configure adapters with sensible defaults
	handlers = {},
	ensure_installed = {
		"debugpy", -- Python debugger
	},
})

-- DAP UI setup
---@diagnostic disable-next-line: missing-fields
dapui.setup({
	icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
	---@diagnostic disable-next-line: missing-fields
	controls = {
		icons = {
			pause = "⏸",
			play = "▶",
			step_into = "⏎",
			step_over = "⏭",
			step_out = "⏮",
			step_back = "b",
			run_last = "▶▶",
			terminate = "⏹",
			disconnect = "⏏",
		},
	},
})

-- Automatically open/close DAP UI when a debug session starts/ends
dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- Python debug adapter
require("dap-python").setup("python3")

-- Keymaps
-- stylua: ignore start
local dap_maps = {
	{ "<F5>",        function() dap.continue() end,                                             "Debug: Start/Continue" },
	{ "<F1>",        function() dap.step_into() end,                                            "Debug: Step Into" },
	{ "<F2>",        function() dap.step_over() end,                                            "Debug: Step Over" },
	{ "<F3>",        function() dap.step_out() end,                                             "Debug: Step Out" },
	{ "<leader>db",  function() dap.toggle_breakpoint() end,                                    "Debug: Toggle Breakpoint" },
	{ "<leader>dB",  function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "Debug: Set Conditional Breakpoint" },
	{ "<F7>",        function() dapui.toggle() end,                                             "Debug: Toggle UI" },
}
-- stylua: ignore end

for _, map in ipairs(dap_maps) do
	vim.keymap.set("n", map[1], map[2], { desc = map[3] })
end

-- INFO: iron.nvim (REPL)
vim.pack.add({ "https://github.com/Vigemus/iron.nvim" })

local iron = require("iron.core")
local common = require("iron.fts.common")

iron.setup({
	config = {
		scratch_repl = true, -- don't keep dead REPL buffers around
		close_window_on_exit = true, -- close the split when the process exits
		-- dap_integration = true,   -- optional: route sends to the DAP REPL during a debug session
		repl_definition = {
			python = {
				command = { "ipython", "--no-autoindent" },
				format = common.bracketed_paste_python, -- IPython paste fix (was slime_python_ipython)
				block_dividers = { "# %%", "#%%" }, -- cell markers for send_code_block
			},
			sh = { command = { "zsh" } }, -- or { "bash" }
			javascript = { command = { "node" } },
			typescript = { command = { "node" } },
		},
		repl_open_cmd = "vertical botright 80 split", -- REPL in a right-hand split
		highlight = { italic = true }, -- flash the region you send
		ignore_blank_lines = true,
	},
	-- no `keymaps = {}` block — keybinds are below so they have descriptions
})

-- stylua: ignore start
local iron_maps = {
	-- sends
	{ "<leader>rs", function() iron.run_motion("send_motion") end,  "Send (motion)",      "n" },
	{ "<leader>rs", function() iron.visual_send() end,              "Send selection",     "x" },
	{ "<leader>rl", function() iron.send_line() end,                "Send line",          "n" },
	{ "<leader>rp", function() iron.send_paragraph() end,           "Send paragraph",     "n" },
	{ "<leader>rc", function() iron.send_code_block(false) end,     "Send cell",          "n" },
	{ "<leader>rn", function() iron.send_code_block(true) end,      "Send cell + next",   "n" },
	{ "<leader>rf", function() iron.send_file() end,                "Send file",          "n" },
	-- signals
	{ "<leader>ri", function() iron.send(nil, string.char(3)) end,  "Interrupt (Ctrl-C)", "n" },
	{ "<leader>rk", function() iron.send(nil, string.char(12)) end, "Clear screen",       "n" },
	{ "<leader>rq", function() iron.close_repl() end,               "Close REPL",         "n" },
	-- control
	{ "<leader>rt", "<cmd>IronRepl<cr>",                            "Toggle REPL",        "n" },
	{ "<leader>rR", "<cmd>IronRestart<cr>",                         "Restart REPL",       "n" },
	{ "<leader>rF", "<cmd>IronFocus<cr>",                           "Focus REPL",         "n" },
}
-- stylua: ignore end
--
for _, m in ipairs(iron_maps) do
	vim.keymap.set(m[4] or "n", m[1], m[2], { desc = m[3], silent = true })
end
