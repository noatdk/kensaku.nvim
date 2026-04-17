--- Optional `/` and `?` live highlight using the Migemo regex (built-in incsearch only matches literal cmdline text).

local M = {}

local augroup = "KensakuLivePreview"
local match_id = nil
local saved_incsearch = nil

local function clear_match()
	if match_id then
		pcall(vim.fn.matchdelete, match_id)
		match_id = nil
	end
end

local function update()
	clear_match()
	local line = vim.fn.getcmdline()
	if line == "" then
		return
	end
	local p = require("kensaku.search").migemo_vim_pattern_for_cmdline(line)
	if not p then
		return
	end
	local ok, id = pcall(vim.fn.matchadd, "IncSearch", p, 100)
	if ok then
		match_id = id
	end
end

function M.setup()
	if vim.fn.exists("#" .. augroup) == 1 then
		return
	end
	vim.api.nvim_create_augroup(augroup, { clear = true })

	vim.api.nvim_create_autocmd("CmdlineEnter", {
		group = augroup,
		pattern = { "/", "?" },
		callback = function()
			saved_incsearch = vim.o.incsearch
			vim.o.incsearch = false
		end,
	})

	vim.api.nvim_create_autocmd("CmdlineChanged", {
		group = augroup,
		pattern = { "/", "?" },
		callback = update,
	})

	vim.api.nvim_create_autocmd("CmdlineLeave", {
		group = augroup,
		pattern = { "/", "?" },
		callback = function()
			clear_match()
			if saved_incsearch ~= nil then
				vim.o.incsearch = saved_incsearch
				saved_incsearch = nil
			end
		end,
	})

	-- Lazy-loaded plugins may register after CmdlineEnter for `/` already ran.
	local t = vim.fn.getcmdtype()
	if t == "/" or t == "?" then
		saved_incsearch = vim.o.incsearch
		vim.o.incsearch = false
		update()
	end
end

return M
