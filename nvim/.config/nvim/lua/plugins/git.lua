---@diagnostic disable: undefined-field

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
