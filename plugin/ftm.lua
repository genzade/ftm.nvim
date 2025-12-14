local cmdparse = require('mega.cmdparse')
local parser = cmdparse.ParameterParser.new({ name = 'Ftm', help = 'Unicode Parameters.' })

parser:add_parameter({
  name = 'name',
  help = 'Name you can assign this terminal. This helps with managment of multiple terminals (required).',
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
