local has_telescope, _ = pcall(require, 'telescope')
if not has_telescope then
  vim.notify(
    string.format('This plugins requires nvim-telescope/telescope.nvim'),
    vim.log.levels.ERROR
  )
end

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values
local previewers = require('telescope.previewers')
local ftm_manager = require('ftm')
local ftm_utils = require('ftm.utils')

local function entry_maker(entry)
  local cmd = ftm_utils.is_cmd(entry.cmd)
  if type(cmd) == 'table' then
    cmd = table.concat(cmd, ' ')
  end

  return {
    display = string.format('%s %s (%s)', entry.status, entry.name, cmd),
    ordinal = entry.name, -- Use name for default sorting
    value = entry, -- Store the full, original terminal info object
  }
end

local function list_terminals(opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = 'Floating Terminals',

      -- Use the finder to process our list
      finder = finders.new_table({
        results = ftm_manager.list_terminals(),
        entry_maker = entry_maker,
      }),

      -- Use a standard sorter
      sorter = conf.generic_sorter(opts),

      previewer = previewers.new_buffer_previewer({
        -- this is not the prettiest preview...
        define_preview = function(self, entry, _)
          local bufnr = entry.value.instance.buf

          if not bufnr or bufnr == 0 or vim.api.nvim_buf_is_loaded(bufnr) == false then
            -- Handle cases where the buffer doesn't exist or is invalid
            local lines = {
              'No valid buffer selected or buffer not loaded.',
              'Bufnr: ' .. tostring(bufnr),
            }
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            return
          end

          vim.api.nvim_buf_set_lines(
            self.state.bufnr,
            0,
            -1,
            false,
            vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          )

          require('telescope.previewers.utils').highlighter(
            self.state.bufnr,
            'tmux',
            { preview = { treesitter = { enable = {} } } }
          )
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        -- This remaps the default <CR> action
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)

          local entry = action_state.get_selected_entry()

          if entry and entry.value and entry.value.instance then
            -- We have the instance, just call its toggle method!
            entry.value.instance:toggle()
          end
        end)

        map({ 'i', 'n' }, '<c-d>', function()
          local entry = action_state.get_selected_entry()
          if entry and entry.value and entry.value.instance then
            local name = entry.value.name
            -- local bufnr = entry.value.instance.buf
            ftm_manager.destroy({ name = name, force = true })
            vim.notify(
              string.format('[FTM] Destroyed terminal "%s".', name),
              vim.log.levels.INFO,
              { title = 'FTM' }
            )

            local picker = action_state.get_current_picker(prompt_bufnr)
            picker:refresh(
              finders.new_table({
                results = ftm_manager.list_terminals(),
                entry_maker = entry_maker,
              }),
              { reset_prompt = true }
            )
          end
        end)

        return true
      end,
    })
    :find()
end

return require('telescope').register_extension({
  exports = {
    ftm = list_terminals,
  },
})
