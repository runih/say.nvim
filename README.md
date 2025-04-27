# say.nvim

This is a simple plugin for Neovim that allows you to use the `say` command to read text aloud.
It uses the `say` command available on macOS system.

## Installation

requires:

- MacOS
- Neovim 0.11 or higher.
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

### Using Lazy.nvim

```lua
{
  'runih/say.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  lazy = true,
  keys = {
    {
      mode = { 'v' },
      '<c-t>',
      function()
        require('say').selected()
      end,
      desc = 'Say selected text',
    },
  },
  opts = {
    voice = 'Jamie',
    show_notification = true,
  },
}
```

## Options

- `voice`: The voice to use for the `say` command. Default is `Jamie`, a voice available on macOS.
- `show_notification`: Whether to show a notification in Neovim when the text is read aloud. Default is `true`.

## Usage

Select the text you want to read aloud in visual mode and press `<c-t>`. The selected text will be
passed to the `say` command, and it will be read aloud using the specified voice.

It is possible to change the voice. Press `<leader>tv` to change the voice. You can switch between the different languages.

*Note*: Remember to download the voices you want to use. You can do this by going to System Preferences > Accessibility > Speech
and selecting the voice you want to download. Once downloaded, you can use it in the plugin.
