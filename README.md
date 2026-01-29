# mini-pick-preview.nvim

> ⚠️ **This project is currently under development.**

Standalone preview window for [mini.pick](https://github.com/nvim-mini/mini.nvim).

![demo.gif](demo/demo.gif)

## Overview

`mini-pick-preview.nvim` extends mini.pick with an independent, always-visible preview window displayed on the right side. Unlike mini.pick's native single-window design where TAB toggles preview mode, this plugin provides a persistent preview window for a more comfortable browsing experience.

## Installation

Use your preferred plugin manager.

## Setup

Initialize in your Neovim configuration:

```lua
require('mini-pick-preview').setup()
```

That's it. The preview window appears automatically on the right side whenever mini.pick is active.

## Features

- ✨ Automatic preview window on the right side
- 🎨 Inherits picker's border and highlight styles
- 🎯 Works with all mini.pick built-in pickers (files, buffers, etc.)
- ⚡ Lightweight and non-intrusive

## Requirements

- mini.nvim (mini.pick module)

## Troubleshooting

### Preview window is hidden behind mini.pick's main window (search window)

When using certain configurations, the preview window may be hidden behind mini.pick's main window (search window).

The preview window's position is calculated based on the search window's configuration values. In the example below, the search window's `col` is `0`, but it is actually drawn at position `52`. `52` is the sum of `width + border`.

```lua
require("mini.pick").setup({
  window = {
    config = {
      width = 50,
      anchor = "NE",
    },
  },
})
```

If the preview window is hidden behind the search window, please explicitly specify `col`, `width`, and `anchor` in mini.pick's setup:

