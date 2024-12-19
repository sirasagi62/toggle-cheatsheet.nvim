## toggle-cheatsheet.nvim

### Overview 

toggle-cheatsheet.nvim is a Neovim Lua plugin that provides a cheat sheet window for displaying keymaps and other information. This plugin allows you to easily toggle the cheat sheet window on and off, and it can be configured to persist across tab changes.
### Example

```lua
-- loading the plugin
local tcs = require('toggle-cheatsheet').setup(true)

-- make your own cheat sheet
local cs1 = tcs.createCheatSheetFromSubmodeKeymap(
  tcs.conf{
    {"h","←"},
    {"j","↓"},
    {"k","↑"},
    {"l","→"},
    {"gg","Go to the top"},
    {"G","Go to the bottom"},
    {"%","Go to matching bracket"}
  }
)

-- define another cheat sheet
local cs2 = tcs.createCheatSheetFromSubmodeKeymap(
  tcs.conf{
    {"Ctrl + f", "Scroll forward one full screen."},
    {"Ctrl + b", "Scroll backward one full screen."},
    {"Ctrl + d", "Scroll down half a screen."},
    {"Ctrl + u", "Scroll up half a screen."},
    {"Ctrl + g", "Show the current file name and line number."}
  }
)

-- assign your favorite keymap to toggle cheat sheet windows
vim.keymap.set("n","<Leader>q",function()
    tcs.toggle(cs1)
end)
vim.keymap.set("n","<Leader>Q",function()
    tcs.toggle(cs2)
end)
```

### Setup

To use the plugin, you need to call the `setup` function and pass a boolean value indicating whether the cheat sheet should persist across tab changes. It is recommended to set this value to `true` unless you have a specific reason not to.

```
  require('toggle-cheatsheet').setup(true)
```

### API References
#### Configuration

The plugin provides several functions for configuring and using the cheat sheet window.

#### `conf(easymap)` 

Converts a tuple-based "easy" keymap configuration to a "formal" format compatible with the "sirasagi62/nvim-submode" keymap format.

```
  local easymap = {
    {"map1", "desc1"},
    {"map2", "desc2"},
    -- ...
  }

  local formalTbl = require('togglecheatsheet').conf(easymap)
```

#### `createCheatSheetFromSubmodeKeymap(smKeymap)` 

Converts a keymap list in the "formal" format to a text string that can be displayed in the cheat sheet window.

```
  local smKeymap = {
    {map = "map1", desc = "desc1"},
    {map = "map2", desc = "desc2"},
    -- ...
  }

  local tcsText = require('toggle-cheatsheet').createCheatSheetFromSubmodeKeymap(smKeymap)
```

### Using the Cheat Sheet Window

The plugin provides several functions for opening, closing, and toggling the cheat sheet window.

#### `openCheatSheetWin(text)` 

Opens the cheat sheet window and displays the given text.

```
  require('toggle-cheatsheet').openCheatSheetWin(tcsText)
```

#### `closeCheatSheetWin()` 

Closes the cheat sheet window.

```
  require('toggle-cheatsheet').closeCheatSheetWin()
```

#### `toggle(text)` 

Toggles the cheat sheet window on and off. If the window is already open and displaying the same text, it will be closed. Otherwise, it will be opened.

```
  require('toggle-cheatsheet').toggle(tcsText)
```

### Persistence Cheat Sheet Window Across Tab Changes 

If the `setup` function is called with `true` as the argument, the cheat sheet window will persist across tab changes. This means that if you switch to a different tab, the cheat sheet window will remain open and displaying the same text.

