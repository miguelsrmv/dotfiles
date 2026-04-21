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

-- Undo and backups
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = true -- Persist undo history across sessions (undo even after closing a file)
vim.opt.undolevels = 10000 -- Maximum number of undo steps to keep

-- Timing
vim.opt.updatetime = 250 -- Write swap file and trigger CursorHold faster (250ms vs 4s default)
vim.opt.timeoutlen = 300 -- Shorten wait time for a key sequence to complete (affects which-key popup)
vim.o.ttimeoutlen = 10 -- Shorten wait time for terminal key codes (reduces ESC key delay)

-- Create socket for external programs (ie themeSwitcher)
vim.fn.serverstart("/tmp/nvim-" .. vim.fn.getpid() .. ".sock")

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
