--- :checkhealth kensaku
local M = {}

function M.check()
	vim.health.start("kensaku")

	local ver = vim.version()
	local patch = ver.patch or 0
	if ver.major == 0 and ver.minor < 10 then
		vim.health.error(
			string.format("Neovim 0.10+ required; got %d.%d.%d", ver.major, ver.minor, patch)
		)
	else
		vim.health.ok(
			string.format("Neovim %d.%d.%d satisfies requirement (0.10+)", ver.major, ver.minor, patch)
		)
	end

	local ok_lm, luamigemo_err = pcall(require, "luamigemo")
	if ok_lm then
		vim.health.ok("luamigemo module loads")
	else
		vim.health.error("luamigemo not found: " .. tostring(luamigemo_err))
		vim.health.info("Add delphinus/luamigemo to 'runtimepath' (e.g. lazy.nvim `dependencies`).")
	end

	local dict = vim.g.kensaku_migemo_dict
	if type(dict) == "string" and dict ~= "" then
		local f = io.open(dict, "rb")
		if f then
			f:close()
			vim.health.ok("kensaku_migemo_dict: " .. dict .. " (readable)")
		else
			vim.health.warn("kensaku_migemo_dict points to a file that is not readable: " .. dict)
		end
	else
		vim.health.info("kensaku_migemo_dict not set — luamigemo default dictionary is used")
	end

	if ok_lm then
		local migemo = require("kensaku.migemo")
		local ok_q, res = pcall(migemo.query, "a")
		if ok_q and type(res) == "string" and res ~= "" then
			vim.health.ok([[Migemo smoke test: query("a") returned a non-empty pattern]])
		elseif not ok_q then
			vim.health.warn("Migemo query failed: " .. tostring(res))
		else
			vim.health.warn([[Migemo query("a") returned an empty pattern]])
		end
	end

	vim.health.info("For LuaJIT and dictionary details, run :checkhealth luamigemo")
end

return M
