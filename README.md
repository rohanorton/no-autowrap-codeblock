# no-autowrap-codeblock.nvim

Deactivate Neovim autowrap on markdown codeblocks.

## About

I like autowrap when writing markdown (`:h formatoptions`). Unfortunately,
vim's autowrap feature doesn't quite know the difference between paragraph text
and codeblocks, leading to ... frustration.

This plugin hopes to rectify the situation.

## Installation

Use whatever package manager you like. My personal favourite, `packer`:

```lua
use "rohanorton/no-autowrap-codeblock.nvim"
```

## Usage

The functionality can be turned on:

```lua
require('no-autowrap-codeblock').enable()
```

And it can be turned off:

```lua
require('no-autowrap-codeblock').disable()
```
