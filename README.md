# kensaku.nvim

**Neovim 用 Migemo 検索:** `/` または `?` でローマ字を入力し Enter を押すと、コマンドラインが対応する日本語（ひらがな・カタカナ・漢字のゆらぎなど）にマッチする Vim 正規表現へ置き換わります。

元となった実装は **[kensaku-search.vim](https://github.com/lambdalisue/kensaku-search.vim)** および **[kensaku.vim](https://github.com/lambdalisue/kensaku.vim)** です。変換には **[delphinus/luamigemo](https://github.com/delphinus/luamigemo)**（LuaJIT、辞書同梱）を使います。本プラグインと一緒に依存として追加してください。

**English:** [README.en.md](README.en.md)

## 要件

- Neovim **0.10 以降**
- **`'runtimepath'`** 上に **[luamigemo](https://github.com/delphinus/luamigemo)**（**インストール**を参照）。Node などは不要です。
- 任意: `vim.g.kensaku_migemo_dict` — 別の `migemo-compact-dict` を使う場合のパス（luamigemo のドキュメント参照）

## インストール

**lazy.nvim** の例:

```lua
{
  "noatdk/kensaku.nvim",
  dependencies = { "delphinus/luamigemo" },
  lazy = true,
  event = "CmdlineEnter",
  opts = {
    live_preview = true, -- 入力中にハイライト
  },
  config = function(_, opts)
    require("kensaku").setup(opts)
  end,
}
```

ローカルにクローンした場合は `"noatdk/kensaku.nvim"` の代わりに `dir = vim.fn.expand("~/path/to/kensaku.nvim")` を指定してください。LazyVim を使う場合は、カスタムプラグインが起動時にまとめて読み込まれないよう `lazy = true` にしてください。

**Neovim 0.12 の [`vim.pack`](https://neovim.io/doc/user/lua.html#vim.pack)**（`:h vim.pack`）:

```lua
vim.pack.add({ "https://github.com/delphinus/luamigemo", "https://github.com/noatdk/kensaku.nvim" })
require("kensaku").setup()
```

読み込みを遅らせる場合は、`CmdlineEnter` の autocommand の中で `vim.pack.add` と `setup()` を呼び、`once = true` にします。

手動配置: `'runtimepath'` または [packages](https://neovim.io/doc/user/repeat.html#packages) と `:packadd`。

更新: `:lua vim.pack.update()`（`:h vim.pack.update()`）。

**このリポジトリを開発するとき:** `make submodules` で `deps/luamigemo` を用意してください（`make test` で使用）。

### `setup()` の内容

- `cmap <expr> <Plug>(kensaku-search-replace)` — Migemo 置換だけ（独自マッピング用）
- `cmap <expr> <CR>` — `/` / `?` ではローマ字を Migemo 正規表現に置き換えて確定。それ以外は通常の Enter
- `live_preview = true` — `/` / `?` 入力中、バッファ内で Migemo に合う箇所をハイライト（`IncSearch` 相当の `matchadd`）。標準の `incsearch` はコマンドラインの文字そのものにしか効かないため、検索コマンド中だけオフにし、終了時に元に戻します。

ローマ字判定の上書き:

- `vim.g.kensaku_search_pattern` または `vim.g['kensaku_search#pattern']`

## API

```lua
local pattern = require("kensaku").query("kensaku") -- Migemo 正規表現文字列
```

## ライセンス

MIT — `LICENSE` を参照してください。
