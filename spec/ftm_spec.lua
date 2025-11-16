local plugin = require('ftm')

describe('Test example', function()
  it('Test can access vim namespace', function()
    plugin.setup()

    assert.are.same(vim.trim('  a '), 'a')
  end)
end)
