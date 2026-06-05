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

-- INFO: Vim-slime
vim.pack.add({ "https://github.com/jpalardy/vim-slime" })

vim.g.slime_target = "tmux"
vim.g.slime_default_config = {
	socket_name = "default",
	target_pane = "{last}", -- (swap to ":.1" once your layout settles)
}
vim.g.slime_dont_ask_default = 1
vim.g.slime_python_ipython = 1 -- <- the important one for IPython
vim.g.slime_cell_delimiter = "# %%" -- <- what marks a cell boundary

vim.g.slime_no_mappings = 1 -- <- disable default C-c C-c; we map our own

vim.keymap.set("x", "<leader>Ss", "<Plug>SlimeRegionSend", { remap = true }) -- send visual selection
vim.keymap.set("n", "<leader>Ss", "<Plug>SlimeParagraphSend", { remap = true }) -- send paragraph (normal mode)
vim.keymap.set("n", "<leader>Sl", "<Plug>SlimeLineSend", { remap = true }) -- send the line
vim.keymap.set("n", "<leader>Sc", "<Plug>SlimeSendCell", { remap = true }) -- send the whole cell
vim.keymap.set("n", "<leader>Sv", "<Plug>SlimeConfig", { remap = true }) -- re-point the target pane
