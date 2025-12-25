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

local ftm_help = [[
FTM is a floating terminal manager for Neovim.
Use it to easily manage multiple floating terminal instances.

Usage: :Ftm <SUBCOMMAND> [ARGS...]
  Available subcommands:
    toggle   Toggle a terminal open/closed.
    close    Close a terminal or all terminals.
  Use ':Ftm <SUBCOMMAND> -h' for help on a specific subcommand.
]]

local toggle_help = [[
Usage: :Ftm toggle <TERMINAL_NAME> <CMD>
  TERMINAL_NAME is required.
  CMD is optional command to run in the terminal.
]]

local close_help = [[
Usage: :Ftm close <TERMINAL_NAME> [--force | -f] 
       :Ftm close --all | -a
  TERMINAL_NAME is required.
  'force' is an optional argument to force close the terminal.
  Use '--all' or '-a' to close all open terminals.
]]

---@type table<string, MyCmdSubcommand>
local subcommand_tbl = {
  help = {
    impl = function(args, opts)
      vim.notify(ftm_help, vim.log.levels.INFO)
    end,
  },
  toggle = {
    impl = function(args, opts)
      if #args == 0 then
        vim.notify(
          "Ftm: 'toggle' requires a terminal name as the first argument.",
          vim.log.levels.ERROR,
          { title = 'FTM' }
        )
        return
      end

      if args[1] == '-h' or args[1] == '--help' then
        vim.notify(toggle_help, vim.log.levels.INFO)
        return
      end

      if vim.fn.executable(args[2]) == 0 and args[2] ~= nil then
        vim.notify(
          string.format("CMD '%s' is not executable.", args[2]),
          vim.log.levels.ERROR,
          { title = 'FTM' }
        )
        return
      end

      require('ftm').toggle({
        name = args[1],
        cmd = args[2], -- Optional command
      })
    end,
    complete = function(subcmd_arg_lead)
      local terminal_names = {}

      for name, _ in pairs(require('ftm').terminals) do
        table.insert(terminal_names, name)
      end

      return vim.iter(terminal_names):filter(function(term_name)
          -- If the user has typed `:Ftm toggle te`,
          -- this will match 'terminal1', 'term2', etc.
          return term_name:find(subcmd_arg_lead) ~= nil
        end)
        :totable()
    end,
  },
  close = {
    impl = function(args, opts)
      if args[1] == '-h' or args[1] == '--help' then
        vim.notify(close_help, vim.log.levels.INFO)
        return
      end

      if args[1] == '-a' or args[1] == '--all' then
        if next(require('ftm').terminals) == nil then
          vim.notify(
            "No terminals are currently open.",
            vim.log.levels.WARN,
            { title = 'FTM' }
          )

          return
        else
          local open_terms = {}

          for name, _ in pairs(require('ftm').terminals) do
            table.insert(open_terms, name)
          end

          vim.notify(
            "Closing all open terminals: " .. table.concat(open_terms, ", "),
            vim.log.levels.INFO,
            { title = 'FTM' }
          )

          require('ftm').destroy_all()

          return
        end
      end

      if next(require('ftm').terminals) == nil then
        vim.notify(
          "No terminals are currently open.",
          vim.log.levels.WARN,
          { title = 'FTM' }
        )

        return
      else
        if #args == 0 then
          local open_terms = {}

          for name, _ in pairs(require('ftm').terminals) do
            table.insert(open_terms, name)
          end

          vim.notify(
            "Open terminals: " .. table.concat(open_terms, ", "),
            vim.log.levels.INFO,
            { title = 'FTM' }
          )

          return
        else
          if require('ftm').terminals[args[1]] == nil then
            vim.notify(
              string.format("Terminal '%s' does not exist.", args[1]),
              vim.log.levels.ERROR,
              { title = 'FTM' }
            )

            return
          end
        end
      end

      require('ftm').close({
        name = args[1],
        force = args[2] == '-f' or args[2] == '--force', -- Optional 'force' argument
      })
    end,
    complete = function(subcmd_arg_lead)
      local terminal_names = {}

      for name, _ in pairs(require('ftm').terminals) do
        table.insert(terminal_names, name)
      end

      return vim.iter(terminal_names):filter(function(term_name)
          return term_name:find(subcmd_arg_lead) ~= nil
        end)
        :totable()
    end,
  },
}

local function ftm_cmd(opts)
  local fargs = opts.fargs
  local subcommand_key = fargs[1]
  -- Get the subcommand's arguments, if any
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local subcommand = subcommand_tbl[subcommand_key]
  if not subcommand then
    vim.notify("Ftm: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
    return
  end
  -- Invoke the subcommand
  subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command("Ftm", ftm_cmd, {
  nargs = "+",
  desc = "FTM command with subcommand completions",
  complete = function(arg_lead, cmdline, _)
    -- Get the subcommand.
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Ftm[!]*%s(%S+)%s(.*)$")
    if subcmd_key 
      and subcmd_arg_lead 
      and subcommand_tbl[subcmd_key] 
      and subcommand_tbl[subcmd_key].complete
    then
      -- The subcommand has completions. Return them.
      return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
    end
    -- Check if cmdline is a subcommand
    if cmdline:match("^['<,'>]*Ftm[!]*%s+%w*$") then
      -- Filter subcommands that match
      local subcommand_keys = vim.tbl_keys(subcommand_tbl)
      return vim.iter(subcommand_keys)
        :filter(function(key)
          return key:find(arg_lead) ~= nil
        end)
        :totable()
    end
  end,
  bang = true, -- If you want to support ! modifiers
})
