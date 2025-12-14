# FTM.nvim

A no nonsense floating terminal management plugin.

## Features

- Create and toggle multiple terminals in your neovim session.
- Use your favourite picker to choose from any number of your created terminals (currently only supports Telescope)

## Requirements

- Neovim >= 0.11.0
- [Any other dependencies]

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'genzade/ftm.nvim',
  dependencies = {
    'ColinKennedy/mega.cmdparse',
    'ColinKennedy/mega.logging',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require("ftm").setup()
  end
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
    require("ftm").setup()
  end
}
```

## Usage

TODO: add config options here including defaults

```lua
require("ftm").setup({
  -- your config here
})
```

## Commands

Create terminals on the fly with the following command;

- `:Ftm NAME CMD` – where `NAME` is whatever you desire and `CMD` is optional.
