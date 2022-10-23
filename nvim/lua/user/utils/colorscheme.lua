local M = {}

---@param colorscheme string
M.set_colorscheme = function(colorscheme)
	local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
	if not status_ok then
		local fallback_scheme = "default"
		vim.notify("colorscheme " .. colorscheme .. " not found!")
		vim.cmd("colorscheme " .. fallback_scheme)
		return
	end
end

return M
