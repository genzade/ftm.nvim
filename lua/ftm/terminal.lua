local U = require('ftm.utils')

--- @class Terminal
--- @field win number|nil
--- @field buf number|nil
--- @field terminal number|nil
--- @field config table
--- @field last_win number|nil
--- @field prev_win number|nil
--- @field last_pos table|nil
local Terminal = {}

--- Creates a new terminal instance.
--- @return Terminal
function Terminal:new()
  return setmetatable(
    { win = nil, buf = nil, terminal = nil, config = U.defaults },
    { __index = self }
  )
end

--- Setup terminal configuration.
--- @param cfg table|nil
--- @return Terminal
function Terminal:setup(cfg)
  if not cfg then
    vim.notify(
      '[FTM] setup() is optional. Please remove it!',
      vim.log.levels.WARN,
      { title = 'FTM' }
    )
    return self
  end

  self.config = vim.tbl_deep_extend('force', self.config, cfg)

  return self
end

--- Store window and buffer references.
--- @param win number
--- @param buf number
--- @return Terminal
function Terminal:store(win, buf)
  self.win = win
  self.buf = buf

  return self
end

--- Remember the current cursor position and window.
--- @return Terminal
function Terminal:remember_cursor()
  self.last_win = vim.api.nvim_get_current_win()
  self.prev_win = vim.fn.winnr('#')
  self.last_pos = vim.api.nvim_win_get_cursor(self.last_win)

  return self
end

--- Restore the previously remembered cursor position and window.
--- @return Terminal
function Terminal:restore_cursor()
  if self.last_win and self.last_pos ~= nil then
    if self.prev_win > 0 then
      vim.cmd(('silent! %s wincmd w'):format(self.prev_win))
    end

    if U.is_win_valid(self.last_win) then
      vim.api.nvim_set_current_win(self.last_win)
      vim.api.nvim_win_set_cursor(self.last_win, self.last_pos)
    end

    self.last_win = nil
    self.prev_win = nil
    self.last_pos = nil
  end

  return self
end

--- Create a new buffer for the terminal.
--- @return number buf
function Terminal:create_buf()
  -- If previous buffer exists then return it
  local prev = self.buf

  if U.is_buf_valid(prev) then
    print(vim.inspect(prev))
    return prev
  end

  local buf = vim.api.nvim_create_buf(false, true)

  -- this ensures filetype is set on first run
  vim.api.nvim_set_option_value('filetype', self.config.ft, { buf = buf })

  return buf
end

--- Resize the floating terminal window.
--- @return Terminal
function Terminal:resize()
  -- Only attempt to resize if the floating window is currently open and valid
  if U.is_win_valid(self.win) then
    local cfg = self.config
    local dim = U.get_dimension(cfg.dimensions)

    vim.api.nvim_win_set_config(self.win, {
      relative = 'editor',
      width = dim.width,
      height = dim.height,
      col = dim.col,
      row = dim.row,
    })

    vim.api.nvim_set_current_win(self.win)
  end

  return self
end

--- Close the terminal window and optionally force buffer cleanup.
--- @param force boolean|nil
--- @return Terminal
function Terminal:close(force)
  if not U.is_win_valid(self.win) then
    return self
  end

  vim.api.nvim_win_close(self.win, force or false)

  self.win = nil

  if force then
    if U.is_buf_valid(self.buf) then
      vim.api.nvim_buf_delete(self.buf, { force = true })
    end

    vim.fn.jobstop(self.terminal)

    self.buf = nil
    self.terminal = nil
  end

  self:restore_cursor()

  return self
end

--- Handle terminal job exit.
--- @param job_id number
--- @param code number
--- @param ... any
function Terminal:handle_exit(job_id, code, ...)
  if self.config.auto_close and code == 0 then
    self:close(true)
  end
  if self.config.on_exit then
    self.config.on_exit(job_id, code, ...)
  end
end

--- Enter insert mode in the terminal.
--- @return Terminal
function Terminal:prompt()
  vim.cmd.startinsert()
  return self
end

--- Open a terminal job in the buffer.
--- @return Terminal
function Terminal:open_term()
  -- NOTE: `termopen` fails if the current buffer is modified
  self.terminal = vim.fn.jobstart(U.is_cmd(self.config.cmd), {
    term = true,
    cwd = vim.fn.getcwd(),
    on_exit = function(...)
      self:handle_exit(...)
    end,
  })

  -- This prevents the filetype being changed to `term` instead of `ftm` when closing the floating window
  vim.api.nvim_set_option_value('filetype', self.config.ft, { buf = self.buf })

  return self:prompt()
end

--- Create a floating window for the terminal.
--- @param buf number
--- @return number win
function Terminal:create_win(buf)
  local cfg = self.config
  local dim = U.get_dimension(cfg.dimensions)
  local win = vim.api.nvim_open_win(buf, true, {
    border = cfg.border,
    relative = 'editor',
    style = 'minimal',
    width = dim.width,
    height = dim.height,
    col = dim.col,
    row = dim.row,
    title = string.format(' FTM: %s ', cfg.name),
    title_pos = 'left',
  })

  vim.api.nvim_set_option_value('winhl', string.format('Normal:%s', cfg.hl), { win = win })
  vim.api.nvim_set_option_value('winblend', cfg.blend, { win = win })

  return win
end

--- Open the terminal window and buffer.
--- @return Terminal
function Terminal:open()
  -- Move to existing window if the window already exists
  if U.is_win_valid(self.win) then
    return vim.api.nvim_set_current_win(self.win)
  end

  local buf
  if self.buf then
    buf = self.buf
    -- If buf is provided, check if the buffer exists
    if U.is_buf_valid(buf) then
      local win = self:create_win(buf)
      return self:store(win, buf):prompt()
    else
      vim.notify(
        string.format('[FTM] Buffer with id %d does not exist!', buf),
        vim.log.levels.ERROR,
        { title = 'FTM' }
      )
      -- return self:open_term()
    end
  end

  self:remember_cursor()

  -- Create new window and terminal if it doesn't exist
  buf = self:create_buf()
  local win = self:create_win(buf)

  -- This means we are just toggling the terminal
  -- So we don't have to call `:open_term()`
  if self.buf == buf then
    return self:store(win, buf):prompt()
  end

  return self:store(win, buf):open_term()
end

--- Toggle the terminal window open/closed.
--- @return Terminal
function Terminal:toggle()
  -- If window is stored and valid then it is already opened, then close it
  if U.is_win_valid(self.win) then
    self:close()
  else
    self:open()
  end

  return self
end

return Terminal
