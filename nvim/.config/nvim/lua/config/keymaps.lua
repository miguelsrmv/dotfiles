-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },

  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Teest shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Split windows horizontally or vertically
vim.keymap.set('n', '<leader>wh', ':split<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>wv', ':vsplit<CR>', { desc = 'Split window vertically' })

-- Molten autocommands
vim.keymap.set('n', '<leader>mi', ':MoltenInit<CR>', { silent = true, desc = 'Initialize the Molten plugin' })
vim.keymap.set('n', '<leader>mdi', ':MoltenDeinit<CR>', { silent = true, desc = 'Deinitialize the Molten plugin' })
vim.keymap.set('n', '<leader>me', ':MoltenEvaluateOperator<CR>', { silent = true, desc = 'Evaluate Operator' })
vim.keymap.set('n', '<leader>ml', ':MoltenEvaluateLine<CR>', { silent = true, desc = 'Evaluate line' })
vim.keymap.set('n', '<leader>mr', ':MoltenReevaluateCell<CR>', { silent = true, desc = 'Re-evaluate cell' })
vim.keymap.set('v', '<leader>me', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, desc = 'Evaluate Visual selection' })
vim.keymap.set('n', '<leader>md', ':MoltenDelete<CR>', { silent = true, desc = 'Molten delete cell' })
vim.keymap.set('n', '<leader>mh', ':MoltenHideOutput<CR>', { silent = true, desc = 'Hide output' })
vim.keymap.set('n', '<leader>ms', ':MoltenShowOutput<CR>', { silent = true, desc = 'Show output' })
vim.keymap.set('n', '<leader>meo', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = 'Show/enter output' })

-- vim: ts=2 sts=2 sw=2 et
