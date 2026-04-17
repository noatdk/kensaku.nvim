# kensaku.nvim

**Migemo search for Neovim:** type romaji in `/` or `?`, press Enter, and the
command line is replaced with a Vim regex that matches the corresponding
Japanese text (hiragana, katakana, kanji variants, and related forms).

Heavily borrowed from **[kensaku-search.vim](https://github.com/lambdalisue/kensaku-search.vim)** and **[kensaku.vim](https://github.com/lambdalisue/kensaku.vim)**.
Conversion uses **[delphinus/luamigemo](https://github.com/delphinus/luamigemo)** (LuaJIT, bundled dictionary) — add it as a dependency next to this plugin.

**Japanese:** [README.md](README.md)

## Requirements

- Neovim **0.10+**.
- **[luamigemo](https://github.com/delphinus/luamigemo)** on `'runtimepath'` (see **Install**). No Node or other runtime.
- Optional: `vim.g.kensaku_migemo_dict` — path to an alternate `migemo-compact-dict` file (see luamigemo docs).

## Install

Example (**lazy.nvim**):

```lua
{
  "noatdk/kensaku.nvim",
  dependencies = { "delphinus/luamigemo" },
  lazy = true,
  event = "CmdlineEnter",
  opts = {
    live_preview = true, -- highlight as you type
  },
  config = function(_, opts)
    require("kensaku").setup(opts)
  end,
}
```

Use `dir = vim.fn.expand("~/path/to/kensaku.nvim")` instead of `"noatdk/kensaku.nvim"` for a local checkout. If you use LazyVim, ensure `lazy = true` so custom plugins are not all loaded at startup.

**Neovim 0.12 [`vim.pack`](https://neovim.io/doc/user/lua.html#vim.pack)** (`:h vim.pack`): install both repos, 

```lua
vim.pack.add({ "https://github.com/delphinus/luamigemo", "https://github.com/noatdk/kensaku.nvim" })
require("kensaku").setup()
```

To defer loading, call `vim.pack.add` + `setup()` inside a `CmdlineEnter` autocommand with `once = true`. 

Plain directories: `'runtimepath'` or [packages](https://neovim.io/doc/user/repeat.html#packages) + `:packadd`.

Updates: `:lua vim.pack.update()` (`:h vim.pack.update()`).

**Developing this repo:** run `make submodules` so `deps/luamigemo` exists (used by `make test`).

### What `setup()` does

- `cmap <expr> <Plug>(kensaku-search-replace)` — Migemo replace segment (for custom mappings).
- `cmap <expr> <CR>` — on `/` / `?`, may replace romaji with a Migemo regex and submit; otherwise behaves like normal Enter.
- `live_preview = true` — while typing `/` or `?`, highlight Migemo matches in the buffer (`matchadd` with `IncSearch`). Builtin `incsearch` only matches literal romaji, so it is turned off for the duration of that cmdline and restored on leave.

Override the romaji detector:

- `vim.g.kensaku_search_pattern` or `vim.g['kensaku_search#pattern']`

## API

```lua
local pattern = require("kensaku").query("kensaku") -- migemo regex string
```

## License

MIT — see `LICENSE`.
