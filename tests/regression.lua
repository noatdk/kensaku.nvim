-- Run: nvim --headless -u NONE -l tests/regression.lua

local script = debug.getinfo(1, "S").source:sub(2)
local tests_dir = vim.fn.fnamemodify(script, ":p:h")
local root = vim.fn.fnamemodify(tests_dir .. "/..", ":p")
vim.opt.runtimepath:prepend(root .. "/deps/luamigemo")
vim.opt.runtimepath:prepend(root)

package.loaded["kensaku"] = nil
package.loaded["kensaku.search"] = nil
package.loaded["kensaku.migemo"] = nil
package.loaded["kensaku.health"] = nil

local function assert_true(cond, msg)
	if not cond then
		error(msg or "assertion failed", 2)
	end
end

local search = require("kensaku.search")
local migemo = require("kensaku.migemo")

local function assert_romaji_case(line, pat, expected_extract, label)
	expected_extract = expected_extract or line
	local ctx = label .. " [" .. line .. "]"
	local ok_m, pos = pcall(vim.fn.match, line, pat)
	assert_true(ok_m, ctx .. ": E5108 match")
	assert_true(pos ~= nil and pos >= 0, ctx .. ": pattern match")
	local ok_s, extracted = pcall(vim.fn.matchstr, line, pat)
	assert_true(ok_s, ctx .. ": E5108 matchstr")
	assert_true(extracted == expected_extract, ctx .. ": extract")
	local q = migemo.query(extracted)
	assert_true(q ~= nil and q ~= "", ctx .. ": migemo query")
	local full_m = [[\m]] .. q
	local ok_search = pcall(vim.fn.search, full_m, "n")
	assert_true(ok_search, ctx .. [[: E54 \m compile]])
	if q:find("\\%(", 1, true) then
		local bad = pcall(vim.fn.search, [[\v]] .. q, "n")
		assert_true(not bad, ctx .. ": E54 no \\v")
	end
end

assert_true(migemo.query("") == "", "empty query")
assert_true(migemo.query(nil) == "", "nil query")

search._ensure_default_pattern()
assert_true(search.replace() == "", "replace outside /?")

local health = require("kensaku.health")
local ok_health, health_err = pcall(health.check)
assert_true(ok_health, "health.check: " .. tostring(health_err))

search._ensure_default_pattern()
local pat = vim.g.kensaku_internal_default_pattern
assert_true(pat ~= nil and pat ~= "", "default pattern set")

local romaji_cases = {
	{ "puroguramu", nil, "program" },
	{ "hensuu", nil, "variable" },
	{ "kansuu", nil, "function" },
	{ "komento", nil, "comment" },
	{ "ripozitori", nil, "repository" },
	{ "mojuuru", nil, "module" },
	{ "neemusupesu", nil, "namespace" },
	{ "mojiretsu", nil, "string" },
	{ "hairetsu", nil, "array" },
	{ "reigai", nil, "exception" },
	{ "hidouki", nil, "async" },
	{ "saiki", nil, "recursion" },
	{ "kurooja", nil, "closure" },
	{ "sutakkufureemu", nil, "stack frame" },
	{ "indekkusu", nil, "index" },
	{ "iteretaa", nil, "iterator" },
	{ "konpairu", nil, "compile" },
	{ "debaggu", nil, "debug" },
	{ "\\khensuu", "hensuu", "backslash-letter prefix" },
}

for _, row in ipairs(romaji_cases) do
	assert_romaji_case(row[1], pat, row[2], row[3])
end

local function expected_replace_seq(line)
	search._ensure_default_pattern()
	local ipat = vim.g.kensaku_internal_default_pattern
	local pos = vim.fn.match(line, ipat)
	if pos == nil or pos < 0 then
		return ""
	end
	local extracted = vim.fn.matchstr(line, ipat)
	if extracted == nil or extracted == "" then
		return ""
	end
	local q = migemo.query(extracted)
	assert_true(q ~= nil and q ~= "", "expected_replace_seq migemo")
	local c_u = vim.api.nvim_replace_termcodes("<C-u>", true, false, true)
	return c_u .. [[\m]] .. q
end

for _, row in ipairs(romaji_cases) do
	local line, label = row[1], row[3]
	local exp = expected_replace_seq(line)
	assert_true(exp ~= "", "replace seq " .. label)
	assert_true(search._replace_contents("/", line) == exp, "_replace_contents / " .. label)
	assert_true(search._replace_contents("?", line) == exp, "_replace_contents ? " .. label)
end

assert_true(search._replace_contents(":", "hensuu") == "", "replace ex-cmdline")
assert_true(search._replace_contents("/", "123") == "", "replace non-romaji")
assert_true(search._replace_contents("/", "") == "", "replace empty line")

local p = search.migemo_vim_pattern_for_cmdline("hensuu")
local cu = vim.api.nvim_replace_termcodes("<C-u>", true, false, true)
assert_true(p ~= nil and search._replace_contents("/", "hensuu") == cu .. p, "migemo_vim_pattern_for_cmdline vs replace")

require("kensaku").setup()
local info = vim.fn.maparg("<CR>", "c", false, true)
assert_true(info ~= nil and next(info) ~= nil, "cmdline <CR> mapped")
assert_true(info.expr == 1, "E223 expr map")
assert_true(info.callback ~= nil, "E223 callback")

io.stdout:write("kensaku.nvim regression: OK\n")
vim.cmd("qa!")
