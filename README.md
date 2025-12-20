# FTM.nvim

A no nonsense floating terminal management plugin.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
  - [lazy.nvim](#lazynvim)
  - [packer.nvim](#packernvim)
- [Configuration](#configuration)
- [Usage](#usage)
- [Commands](#commands)
- [Telescope](#telescope)
- [Thanks](#thanks)

## Features

- Create and toggle multiple terminals in your neovim session.
- Use your favourite picker to choose from any number of your created terminals (currently only supports Telescope)

## Requirements

- Neovim >= 0.11.0

## Installation

Use your favourite plugin manager to install `FTM`.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'genzade/ftm.nvim',
  dependencies = {
    'ColinKennedy/mega.cmdparse',
    'ColinKennedy/mega.logging',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    -- add your options here (see configuration section below)
  }
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "genzade/ftm.nvim",
  requires = {
    'ColinKennedy/mega.cmdparse',
    'ColinKennedy/mega.logging',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require("ftm").setup(
      -- add your options here (see configuration section below)
    )
  end
}
```

## Configuration

The following options can be provided; the default configuration is shown below:

```lua
require("ftm").setup({
     ---Filetype of the terminal buffer
    ---@type string
    ft = 'ftm',

    ---Command to run inside the terminal
    ---NOTE: if given string[], it will skip the shell and directly executes the command
    ---@type fun():(string|string[])|string|string[]
    cmd = os.getenv('SHELL'),

    ---Neovim's native window border. See `:h nvim_open_win` for more configuration options.
    border = 'single',

    ---Close the terminal as soon as shell/command exits.
    ---Disabling this will mimic the native terminal behaviour.
    ---@type boolean
    auto_close = true,

    ---Highlight group for the terminal. See `:h winhl`
    ---@type string
    hl = 'Normal',

    ---Transparency of the floating window. See `:h winblend`
    ---@type integer
    blend = 0,

    ---Object containing the terminal window dimensions.
    ---The value for each field should be between `0` and `1`
    ---@type table<string,number>
    dimensions = {
        height = 0.8, -- Height of the terminal window
        width = 0.8, -- Width of the terminal window
        x = 0.5, -- X axis of the terminal window
        y = 0.5, -- Y axis of the terminal window
    },

    ---Callback invoked when the terminal exits.
    ---See `:h jobstart-options`
    ---@type fun()|nil
    on_exit = nil,
})
```

## Usage

You can configure key mappings as you like to achieve your desired effect. Here is an example of my setup:

```lua
vim.keymap.set({ 'n', 't' }, '<C-t>', function()
  require('ftm').toggle({ name = 'Main' })
end, { desc = 'Toggle built in [T]erminal' })

vim.keymap.set({ 'n', 't' }, '\\r', function()
  require('ftm').toggle({
    name = 'PRY console',
    cmd = 'pry',
  })
end, { desc = 'Toggle [R]uby PRY repl' })

vim.keymap.set({ 'n', 't' }, '\\g', function()
  require('ftm').toggle({
    name = 'Lazygit',
    cmd = 'lazygit',
  })
end, { desc = 'Toggle Lazy[G]it' })

vim.keymap.set({ 'n', 't' }, '<C-x>', function()
  require('ftm').close_all()
end, { desc = 'Close any open terminal' })
```

## Commands

Create terminals on the fly with the following command;

- `:Ftm NAME CMD` – where `NAME` is whatever you desire and `CMD` is optional.

## Telescope

Somewhere in your telescope config, you can add the following;

```lua
require('telescope').load_extension('ftm')

vim.keymap.set(
  'n',
  '<leader>ft', -- or whatever you want
  function()
    telescope.extensions.ftm.ftm()
  end,
  { desc = '[F]loating [T]erminal Picker' }
)
```


## Thanks

Special thanks to the excellent [FTerm](https://github.com/numToStr/FTerm.nvim) plugin, which inspired FTM which adds several enhancements:

- Automatic resizing
- Manage multiple terminals with a picker
- Create terminals on the fly (use responsibly)
