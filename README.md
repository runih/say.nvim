# say.nvim

This is a simple plugin for Neovim that allows you to use the `say` command to read text aloud.
It uses the `say` command available on macOS system.

## Installation

### Using Lazy.nvim

```lua
{
  'runih/say.nvim',
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
