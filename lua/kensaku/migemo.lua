--- Migemo query
local M = {}

--- Romaji → Vim regex (`RXOP_VIM`).
---@param romaji string
---@return string
function M.query(romaji)
	if romaji == nil or romaji == "" then
		return ""
	end
	local ok, m = pcall(require, "luamigemo")
	if not ok then
		vim.notify(
			"kensaku.nvim: luamigemo is required — add plugin `delphinus/luamigemo` (e.g. lazy.nvim `dependencies`):\n"
				.. tostring(m),
			vim.log.levels.ERROR
		)
		return romaji
	end
	local path = vim.g.kensaku_migemo_dict
	if type(path) == "string" and path ~= "" then
		return m.get(path):query(romaji, m.RXOP_VIM)
	end
	return m.query(romaji, m.RXOP_VIM)
end

return M
