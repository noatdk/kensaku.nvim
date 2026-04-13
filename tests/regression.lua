-- Minimal regression suite (no Plenary). Run from plugin root:
--   nvim --headless -u NONE -l tests/regression.lua
-- Guards: E5108 (default pattern / match), E54 ("unmatched (" with \v+migemo), E223 (recursive <CR> map).

local script = debug.getinfo(1, "S").source:sub(2)
local tests_dir = vim.fn.fnamemodify(script, ":p:h")
local root = vim.fn.fnamemodify(tests_dir .. "/..", ":p")
vim.opt.runtimepath:prepend(root .. "/deps/luamigemo")
vim.opt.runtimepath:prepend(root)

package.loaded["kensaku"] = nil
package.loaded["kensaku.search"] = nil
package.loaded["kensaku.migemo"] = nil

---@param cond any
---@param msg string?
local function assert_true(cond, msg)
  if not cond then
    error(msg or "assertion failed", 2)
  end
end

local search = require("kensaku.search")

-- E5108: default romaji pattern must work with vim.fn.match / matchstr (no invalid Lua/Vim pattern).
search._ensure_default_pattern()
local pat = vim.g.kensaku_internal_default_pattern
assert_true(pat ~= nil and pat ~= "", "internal default pattern must be set")
local ok_m, pos = pcall(vim.fn.match, "kensaku", pat)
assert_true(ok_m, "vim.fn.match must not throw (E5108)")
assert_true(pos ~= nil and pos >= 0, "romaji kensaku should match default pattern")
local ok_s, extracted = pcall(vim.fn.matchstr, "kensaku", pat)
assert_true(ok_s, "vim.fn.matchstr must not throw (E5108)")
assert_true(extracted ~= nil and extracted ~= "", "matchstr should extract romaji")

-- E54 + migemo: luamigemo RXOP_VIM is magic-mode; \m + query must compile; \v + same query must not.
local q = require("kensaku.migemo").query("kensaku")
assert_true(q ~= nil and q ~= "", "migemo query(kensaku) must return non-empty (luamigemo on rtp)")
local full_m = [[\m]] .. q
local ok_search = pcall(vim.fn.search, full_m, "n")
assert_true(ok_search, [[E54: \m + migemo must compile as a search pattern (no "unmatched (")]])

if q:find("\\%(", 1, true) then
  local bad = pcall(vim.fn.search, [[\v]] .. q, "n")
  assert_true(not bad, "E54 regression: \\v prefix must not be combined with luamigemo RXOP_VIM output")
end

-- E223: cmdline <CR> must be a single expr map (not <Plug>…<CR> with remap).
require("kensaku").setup()
local info = vim.fn.maparg("<CR>", "c", false, true)
assert_true(info ~= nil and next(info) ~= nil, "cmdline <CR> must be mapped after setup")
assert_true(info.expr == 1, "E223: cmdline <CR> must use expr (avoid recursive mapping)")
assert_true(info.callback ~= nil, "E223: cmdline <CR> should use Lua callback expr")

io.stdout:write("kensaku.nvim regression: OK\n")
vim.cmd("qa!")
