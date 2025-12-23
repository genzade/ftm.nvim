


vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('FTM_ResizeAll', { clear = true }),
  desc = 'Resize all open FTM terminals',
  callback = function()
    -- Iterate through all terminals and resize them if they are open.
    for _, term_instance in pairs(require('ftm').terminals) do
      term_instance:resize()
    end
  end,
})
