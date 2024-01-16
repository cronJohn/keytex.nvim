<div align="center">

# Keytex
##### Like a mutex, but for keyboard shortcuts


<img alt="Keytex logo" height="300" src="/assets/keytex-logo.png" />
</div>

# 🔍 TOC
- [About](#about)
- [Installation](#installation)
- [Getting Started](#getting-started)

# About
- This neovim plugin let's you create keybindings with the following features:
    1. By default, each keybinding must be unique and subsequent mappings won't override current ones.
    2. Let's you search through all keybindings **created using the plugin** and jump to where it was created. If you want to view all keybindings, use `:map`

# Installation
- Neovim 0.8.0+ required

## [lazy](https://github.com/folke/lazy.nvim)
```lua
{
    "cronJohn/keytex.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
}
```

## [packer](https://github.com/wbthomason/packer.nvim)
```lua
use {
    "cronJohn/keytex.nvim"
    requires = { {"nvim-lua/plenary.nvim"} }
}
```

# Getting Started
## Setup
- Run `require('keytex.keybindings').setup()` to setup user commands.

## Create keybindings
- `require('keytex.keybindings').create_keybinding(<mode>, <key>, <action>, <vks_opt>, <usr_opt>)` creates a unique keybinding
    - You can also set `require('keytex.keybindings').create_keybinding` to something like `m` and call it like `m(...)`
    - `vks_opt` is an optional table of `vim.keymap.set` options (|:map-arguments|)
    - `usr_opt` is an optional table to control function behavior
        - `mark` (boolean): If true, add the keybinding to the global list without attempting to create it (default: false).
        - `output` (boolean): If true, print keybinding creation status to the console (default: false).
### Examples
- `require('keytex.keybindings').create_keybinding('n', '<leader>ph', ':lua print("hey")<CR>')`
    - Prints `hey` in normal mode whenever `<leader>ph` is pressed

- `require('keytex.keybindings').create_keybinding({'n', 'v'}, '<leader>ph', ':lua print("hey")<CR>')`
    - Prints `hey` in both normal and visual mode whenever `<leader>ph` is pressed

- `require('keytex.keybindings').create_keybinding('n', '<leader>ao', someFunc)`
    - Runs `someFunc` whenever `<leader>ao` is pressed in normal mode

- `require('keytex.keybindings').create_keybinding('n', key, someFunc, {desc = 'Foo Bar'})`
    - Creates a normal mode keybinding with a description of `Foo Bar`

- `require('keytex.keybindings').create_keybinding('n', key, someFunc, {}, {output=true})`
    - Attempts to create this keybinding and logs, i.e., `print`s whether it was successful or not

- `require('keytex.keybindings').create_keybinding('n', key, someFunc, {unique = false})`
    - Creates a normal mode keybinding using `key` and `someFunc` regardless if it exists or not

## Search keybindings
- `require('keytex.finder').keybinding_picker(<filter>, <opts>)` opens a telescope window and filters using *key* by default
    - `filter` changes the filtering method when set to the following strings:
      - `mode`: Filters by the mode it is in (e.g., *n*ormal, *v*isual, *i*nsert).
      - `key`: Filters by the key combination (default).
      - `action`: Filters by what the keybinding maps to.
      - `description`: Filters by the description of the keybinding.
      - `source`: Filters by the file where the keybinding is defined.
      - `line`: Filters by the line number where the keybinding is located.
    - `opts` is an optional table of additional options for telescope


### Examples
- `require('keytex.finder').keybinding_picker('mode')` searches all keybindings based on the mode
    - Typing something like `n` would only show all *normal* mode keybindings

