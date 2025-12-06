local U = {}

U.defaults = {
  ft = 'ftm',
  cmd = function()
    return assert(
      os.getenv('SHELL'),
      '[ftm] $SHELL is not present! Please provide a shell (`config.cmd`) to use.'
    )
  end,
  border = 'rounded',
  auto_close = true,
  hl = 'Normal',
  blend = 0,
  clear_env = false,
  dimensions = {
    height = 0.95,
    width = 0.95,
    x = 0.5,
    y = 0.5,
  },
}

function U.get_dimension(opts)
  -- get lines and columns
  local cl = vim.o.columns
  local ln = vim.o.lines

  -- calculate our floating window size
  local width = math.ceil(cl * opts.width)
  local height = math.ceil(ln * opts.height - 4)

  -- and its starting position
  local col = math.ceil((cl - width) * opts.x)
  local row = math.ceil((ln - height) * opts.y - 1)

  return {
    width = width,
    height = height,
    col = col,
    row = row,
  }
end

function U.is_win_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

function U.is_buf_valid(buf)
  return buf and vim.api.nvim_buf_is_loaded(buf)
end

function U.is_cmd(cmd)
  return type(cmd) == 'function' and cmd() or cmd
end

return U
