--- Migemo is required only when a romaji segment matches (not on every cmdline <CR>).

local function ensure_default_pattern()
	if vim.g.kensaku_internal_default_pattern ~= nil then
		return
	end
	vim.cmd([[
    let g:kensaku_internal_default_pattern = '\c^\%(\\\a\)\=\zs\(\(\(\([bdfghjklmnpstrzwx]\)\4\=\)\=y\=\([ei]\|[aou]h\=\)\)\|\%(ss\=\|dd\=\)\=h[aiuo]\|cc\=h[aio]\|tt\=su\|n\|-\)\+$'
  ]])
end

---@return string keysequence or '' (let chained <CR> run)
local function replace()
	local t = vim.fn.getcmdtype()
	if t ~= "/" and t ~= "?" then
		return ""
	end
	ensure_default_pattern()
	local line = vim.fn.getcmdline()
	local pat = vim.g["kensaku_search#pattern"]
		or vim.g.kensaku_search_pattern
		or vim.g.kensaku_internal_default_pattern
	local ok_pos, pos = pcall(vim.fn.match, line, pat)
	if not ok_pos or pos == nil or pos < 0 then
		return ""
	end
	local ok_str, extracted = pcall(vim.fn.matchstr, line, pat)
	if not ok_str or extracted == nil or extracted == "" then
		return ""
	end
	local q = require("kensaku.migemo").query(extracted)
	local c_u = vim.api.nvim_replace_termcodes("<C-u>", true, false, true)
	-- luamigemo RXOP_VIM is magic-mode (\|, \%(); \v mis-parses groups → E54.
	return c_u .. [[\m]] .. q
end

return {
	replace = replace,
	---@nodoc Used by tests/minimal regression suite (E5108).
	_ensure_default_pattern = ensure_default_pattern,
}
