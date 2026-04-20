return {
  'ThePrimeagen/harpoon',
  event = 'VeryLazy',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local status_ok, harpoon = pcall(require, 'harpoon')
    if not status_ok then
      return
    end
    harpoon:setup()

    -- picker
    local normalize_list = function(t)
      local normalized = {}
      for _, v in pairs(t) do
        if v ~= nil then
          table.insert(normalized, v)
        end
      end
      return normalized
    end
    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = 'Harpoon Add' })
    vim.keymap.set('n', '<leader>hh', function()
      Snacks.picker {
        finder = function()
          local file_paths = {}
          local list = normalize_list(harpoon:list().items)
          for i, item in ipairs(list) do
            table.insert(file_paths, { text = item.value, file = item.value })
          end
          return file_paths
        end,
        win = {
          input = {
            keys = { ['<C-d>'] = { 'harpoon_delete', mode = { 'n', 'x', 'i' } } },
          },
          list = {
            keys = { ['<C-d>'] = { 'harpoon_delete', mode = { 'n', 'x', 'i' } } },
          },
        },
        actions = {
          harpoon_delete = function(picker, item)
            local to_remove = item or picker:selected()
            harpoon:list():remove { value = to_remove.text }
            harpoon:list().items = normalize_list(harpoon:list().items)
            picker:find { refresh = true }
          end,
        },
      }
    end, { desc = 'Harpoon Menu' })
  end,
}
