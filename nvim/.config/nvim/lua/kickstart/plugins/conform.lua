-- Autoformat
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = {}
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 1000,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      typescript = { 'prettier' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescriptreact = { 'prettier' },
      json = { 'prettier' },
      html = { 'prettier' },
      htmlangular = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      yaml = { 'prettier ' },
      python = { 'black' },
    },
    formatters = {
      ['clang-format'] = {
        prepend_args = { '-style', '{BasedOnStyle: Google, UseTab: Always, IndentWidth: 4, TabWidth: 4}' },
      },
      prettier = {
        command = 'prettier', -- Removed the trailing space
        args = { '--stdin-filepath', '$FILENAME' },
        -- Simple cwd configuration that works properly with fnamemodify
        cwd = function(self, ctx)
          -- Try to find the project root using simpler approach
          local root_dir = vim.fn.getcwd()

          -- Check for prettier config files in the root directory
          local config_files = {
            '.prettierrc',
            '.prettierrc.js',
            '.prettierrc.json',
            '.prettierrc.yml',
            'prettier.config.js',
          }

          for _, file in ipairs(config_files) do
            local config_path = root_dir .. '/' .. file
            if vim.fn.filereadable(config_path) == 1 then
              print('Found prettier config at: ' .. config_path)
              break
            end
          end

          return root_dir
        end,
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
