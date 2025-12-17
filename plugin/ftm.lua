local cmdparse = require('mega.cmdparse')
local parser = cmdparse.ParameterParser.new({ name = 'Ftm', help = 'Unicode Parameters.' })

parser:add_parameter({
  name = 'name',
  help = 'Assign a name to this terminal. This helps with managment of multiple terminals (required).',
})
parser:add_parameter({
  name = 'cmd',
  required = false,
  help = 'Command you can run in this terminal (optional).',
})
parser:set_execute(function(data)
  require('ftm').toggle({ name = data.namespace.name, cmd = data.namespace.cmd })
end)

cmdparse.create_user_command(parser)

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
