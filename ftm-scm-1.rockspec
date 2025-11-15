local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = '3.0'
package = 'ftm'
version = _MODREV .. _SPECREV
description = {
  summary = 'A no nonsense floating terminal for Neovim',
  detailed = [[
  ftm is a simple to use floating terminal plugin for Neovim. Create and manage multiple floating
  terminal windows with ease.
  ]],
  labels = {
    'neovim',
    'plugin',
    'terminal',
  },
  homepage = 'https://github.com/genzade/ftm',
  license = 'GPL-3.0',
}
dependencies = {
  'lua >= 5.1, <= 5.4',
  -- 'plenary.nvim',
}
test_dependencies = {
  'nlua',
}
source = {
  url = 'git://github.com/genzade/ftm',
}
build = {
  type = 'builtin',
  copy_directories = {
    -- Add runtimepath directories, like
    -- 'plugin', 'ftplugin', 'doc'
    -- here. DO NOT add 'lua' or 'lib'.
    'doc',
  },
}
