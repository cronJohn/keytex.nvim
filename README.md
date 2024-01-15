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
- `require('keytex.keybindings').create_keybinding(<mode>, <key>, <action>, <options>, <should_output>)` creates a unique keybinding
    - You can also set `require('keytex.keybindings').create_keybinding` to something like `m` and call it like `m(...)`
    - `options` is an optional table of `:map-arguments` 
    - `should_output` is a boolean defaulted to *false*. If true, log the keybind creation

### Examples
- `require('keytex.keybindings').create_keybinding('n', '<leader>ph', ':lua print("hey")<CR>')`
    - Prints `hey` in normal mode whenever `<leader>ph` is pressed

- `require('keytex.keybindings').create_keybinding({'n', 'v'}, '<leader>ph', ':lua print("hey")<CR>')`
    - Prints `hey` in both normal and visual mode whenever `<leader>ph` is pressed

- `require('keytex.keybindings').create_keybinding('n', '<leader>ao', someFunc)`
    - Runs `someFunc` whenever `<leader>ao` is pressed in normal mode

- `require('keytex.keybindings').create_keybinding('n', key, someFunc, {desc = 'Foo Bar'})`
    - Creates a normal mode keybinding with a description of `Foo Bar`

- `require('keytex.keybindings').create_keybinding('n', key, someFunc, {}, true)`
    - Attempts to create this keybinding and logs, i.e., `print`s whether it was successful or not

- `require('keytex.keybindings').create_keybinding('n', key, someFunc, {unique = false})`
    - Creates a normal mode keybinding using `key` and `someFunc` regardless if it exists or not

## Search keybindings
- `require('keytex.finder').keymap_picker()` opens a telescope window and filters using *key* by default
    - To use a different filtering method, pass one of the following strings as a second argument to the function:
        - `mode` | The mode it is in, e.g., *n*ormal, *v*isual, *i*nsert
        - `key`
        - `action` | What it maps to
        - `description`
        - `source` | What file it is in
        - `line` | What line number it's at

### Examples
- `require('keytex.finder').keymap_picker({}, 'mode')` searches all keybindings based the mode
    - Typing something like `n` would only show all *normal* mode keybindings

