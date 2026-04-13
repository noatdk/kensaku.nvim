--- Kensaku: Migemo search for Neovim
local M = {}

---@class KensakuSetupOpts
---@field default_cr_map? boolean If true (default), map cmdline `<CR>` with one expr (avoids E223 recursive mapping)

--- Cmdline Enter: either kensaku replace + submit, or plain Enter (must be one `<expr>` — chaining `<Plug>…<CR>` with remap retriggers `<CR>` → E223).
local function cmdline_cr_expr()
	local r = require("kensaku.search").replace()
	local cr = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
	if r == "" then
		return cr
	end
	return r .. cr
end

---@param opts KensakuSetupOpts?
function M.setup(opts)
	if vim.g.loaded_kensaku_nvim then
		return
	end
	vim.g.loaded_kensaku_nvim = 1
	opts = opts or {}
	if opts.default_cr_map ~= false then
		vim.keymap.set("c", "<Plug>(kensaku-search-replace)", function()
			return require("kensaku.search").replace()
		end, { expr = true, silent = true, desc = "Kensaku migemo (replace only; no trailing CR)" })
		vim.keymap.set("c", "<CR>", cmdline_cr_expr, {
			expr = true,
			silent = true,
			desc = "Kensaku cmdline Enter (migemo or normal submit)",
		})
	end
end

--- Romaji -> Vim regex (for custom integrations).
---@param romaji string
---@return string
function M.query(romaji)
	return require("kensaku.migemo").query(romaji)
end

return M
