--- Migemo is required only when a romaji segment matches (not on every cmdline <CR>).

local function ensure_default_pattern()
	if vim.g.kensaku_internal_default_pattern ~= nil then
		return
	end
	vim.cmd([[
    let g:kensaku_internal_default_pattern = '\c^\%(\\\a\)\=\zs\(\(\(\([bdfghjklmnpstrzwx]\)\4\=\)\=y\=\([ei]\|[aou]h\=\)\)\|\%(ss\=\|dd\=\)\=h[aiuo]\|cc\=h[aio]\|tt\=su\|n\|-\)\+$'
  ]])
end

--- Romaji cmdline segment → full Vim regex (`\m` + RXOP_VIM) for `/` / `?`, or nil if no migemo replace.
---@param line string
---@return string|nil
local function migemo_vim_pattern_for_cmdline(line)
	ensure_default_pattern()
	local pat = vim.g["kensaku_search#pattern"]
		or vim.g.kensaku_search_pattern
		or vim.g.kensaku_internal_default_pattern
	local ok_pos, pos = pcall(vim.fn.match, line, pat)
	if not ok_pos or pos == nil or pos < 0 then
		return nil
	end
	local ok_str, extracted = pcall(vim.fn.matchstr, line, pat)
	if not ok_str or extracted == nil or extracted == "" then
		return nil
	end
	local q = require("kensaku.migemo").query(extracted)
	if q == nil or q == "" then
		return nil
	end
	-- luamigemo RXOP_VIM is magic-mode (\|, \%(); \v mis-parses groups → E54.
	return [[\m]] .. q
end

---@param cmd_type string vim.fn.getcmdtype() in / or ? (pattern buffer is the romaji only, no leading / or ?).
---@param line string vim.fn.getcmdline()
---@return string keysequence or '' (let chained <CR> run)
local function replace_contents(cmd_type, line)
	if cmd_type ~= "/" and cmd_type ~= "?" then
		return ""
	end
	local p = migemo_vim_pattern_for_cmdline(line)
	if not p then
		return ""
	end
	local c_u = vim.api.nvim_replace_termcodes("<C-u>", true, false, true)
	return c_u .. p
end

---@return string keysequence or '' (let chained <CR> run)
local function replace()
	return replace_contents(vim.fn.getcmdtype(), vim.fn.getcmdline())
end

return {
	replace = replace,
	migemo_vim_pattern_for_cmdline = migemo_vim_pattern_for_cmdline,
	---@nodoc Used by tests/minimal regression suite (E5108).
	_ensure_default_pattern = ensure_default_pattern,
	---@nodoc Headless runs cannot populate cmdline via feedkeys; tests call this with / or ? and getcmdline() text.
	_replace_contents = replace_contents,
}
