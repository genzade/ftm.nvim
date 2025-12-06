describe('ftm plugin', function()
  local plugin

  before_each(function()
    package.loaded['ftm'] = nil
    plugin = require('ftm')
  end)

  describe('#setup', function()
    before_each(function()
      plugin.setup()
    end)

    it('only calls setup once', function()
      local first_config = plugin.config
      plugin.setup({ opt = 'New Value' })
      local second_config = plugin.config

      assert.are.equal(first_config, second_config)
    end)

    it('sets up `VimResize` autocommand for all terminals', function()
      local success, augroups = pcall(vim.api.nvim_get_autocmds, { group = 'FTM_ResizeAll' })
      assert.truthy(success)
      assert.truthy(#augroups > 0)
      assert.are.equal('VimResized', augroups[1].event)
    end)
  end)
end)
