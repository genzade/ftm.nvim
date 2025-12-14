-- main module file
local Terminal = require('ftm.terminal')
local U = require('ftm.utils')

local has_setup = false
local terminals = {}

--- @class FTM
local M = {}

--- Setup FTM terminal manager.
--- @param opts table|nil Optional setup options
function M.setup()
  if has_setup then
    return
  end

  local augroup = vim.api.nvim_create_augroup('FTM_ResizeAll', { clear = true })

  vim.api.nvim_create_autocmd('VimResized', {
    group = augroup,
    desc = 'Resize all open FTM terminals',
    callback = function()
      -- Iterate through all terminals and resize them if they are open.
      for _, term_instance in pairs(terminals) do
        term_instance:resize()
      end
    end,
  })

  has_setup = true
end

--- Get or create a terminal instance by options.
--- @param opts table Options for terminal creation, must include 'name'
--- @return Terminal|nil
local function get_or_create(opts)
  opts = opts or {}
  local name = opts.name

  if not name then
    vim.notify(
      '[FTM] A "name" is required to manage a terminal.',
      vim.log.levels.ERROR,
      { title = 'FTM' }
    )
    return nil
  end

  -- If a terminal with this name already exists, return it.
  if terminals[name] then
    return terminals[name]
  end

  -- Otherwise, create a new one, store it in the registry, and return it.
  --- @type Terminal
  local new_term = Terminal:new():setup(opts)
  terminals[name] = new_term

  return new_term
end

--- Toggle a terminal open/closed.
--- @param opts table Options for terminal (must include 'name')
function M.toggle(opts)
  local term = get_or_create(opts)
  if term then
    term:toggle()
  end
end

--- Open a terminal.
--- @param opts table Options for terminal (must include 'name')
function M.open(opts)
  local term = get_or_create(opts)
  if term then
    term:open()
  end
end

--- Close a terminal.
--- @param opts table Options for terminal (must include 'name')
function M.close(opts)
  local name = opts and opts.name
  local force = opts and opts.force

  if name and terminals[name] then
    terminals[name]:close(force)
  end
end

--- Close all open terminals.
function M.close_all()
  for _, term in pairs(terminals) do
    if U.is_win_valid(term.win) then
      term:close()
    end
  end
end

--- Destroy (close and remove) a terminal.
--- @param opts table Options for terminal (must include 'name')
function M.destroy(opts)
  local name = opts and opts.name
  if name and terminals[name] then
    terminals[name]:close() -- Pass `true` to force cleanup
    terminals[name] = nil -- Remove from the registry
  end
end

--- Destroy (close and remove) all terminals.
function M.destroy_all()
  for name, term in pairs(terminals) do
    term:close(true) -- Pass `true` to force cleanup
    terminals[name] = nil -- Remove from the registry
  end
end

--- List all managed terminals.
--- @return table[] List of terminal info tables
function M.list_terminals()
  local results = {}
  for name, term_instance in pairs(terminals) do
    table.insert(results, {
      name = name,
      -- The terminal is 'open' if its window is currently valid
      status = U.is_win_valid(term_instance.win) and ' ' or ' ',
      cmd = term_instance.config.cmd,
      -- Pass the actual object so picker actions can use it
      instance = term_instance,
    })
  end
  return results
end

--- Open a scratch terminal (not managed in the registry).
--- @param opts table Options for terminal
function M.scratch(opts)
  opts = opts or {}
  opts.auto_close = opts.auto_close or false
  opts.name = opts.name or opts.cmd

  --- @type Terminal
  local term = Terminal:new():setup(opts)

  if term then
    term:open()
  end
end

return M
