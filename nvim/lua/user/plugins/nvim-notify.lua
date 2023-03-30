local status_ok, notify = pcall(require, "notify")
if not status_ok then
	return
end

notify.setup({
	background_colour = "NotifyBackground",
	fps = 60,
	icons = {
		DEBUG = "",
		ERROR = "",
		INFO = "",
		TRACE = "✎",
		WARN = "",
	},
	level = "info",
	minimum_width = 50,
	render = "compact",
	stages = "fade_in_slide_out",
	timeout = 5000,
})

vim.notify = notify
