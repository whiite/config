local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
	return
end

local aperture = {
	[[              .,-:;//;:=,               ]],
	[[		    . :H@@@MM@M#H/.,+%;,          ]],
	[[	     ,/X+ +M@@M@MM%=,-%HMMM@X/,       ]],
	[[	   -+@MM; $M@@MH+-,;XMMMM@MMMM@+-     ]],
	[[	  ;@M@@M- XM@X;. -+XXXXXHHH@M@M#@/.   ]],
	[[  ,%MM@@MH ,@%=             .---=-=:=,. ]],
	[[  =@#@@@MX.,                -%HX$$%%%:; ]],
	[[ =-./@M@M$                   .;@MMMM@MM:]],
	[[ X@/ -$MM/                    . +MM@@@M$]],
	[[,@M@H: :@:                    . =X#@@@@-]],
	[[,@@@MMX, .                    /H- ;@M@M=]],
	[[.H@@@@M@+,                    %MM+..%#$.]],
	[[ /MMMM@MMH/.                  XM@MH; =; ]],
	[[  /%+%$XHH@$=              , .H@@@@MX,  ]],
	[[   .=--------.           -%H.,@@@@@MX,  ]],
	[[   .%MM@@@HHHXX$$$%+- .:$MMX =M@@MM%.   ]],
	[[	  =XMMM@MM@MM#H;,-+HMM@M+ /MMMX=      ]],
	[[	   =%@M@M#@$-.=$@MM@@@M; %M%=         ]],
	[[		 ,:+$+-,/H#MMMMMMM@= =,           ]],
	[[			   =++%%%%+/:-.               ]],
	[[                                        ]],
}

local neovim_text = {
	[[                               __                ]],
	[[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
	[[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
	[[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
	[[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
	[[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
}

local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = neovim_text
dashboard.section.buttons.val = {
	dashboard.button("f", "   Find file", ":Telescope find_files <CR>"),
	dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("P", "  Find project", ":Telescope projects <CR>"),
	dashboard.button("r", "󰈢  Recently used files", ":Telescope oldfiles <CR>"),
	dashboard.button("T", "󰊄  Find text", ":Telescope live_grep <CR>"),
	dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
	dashboard.button("q", "󰗼  Quit Neovim", ":qa<CR>"),
}

local function footer()
	local total_plugins = require("lazy").stats().count
	local datetime = os.date(" %d-%m-%Y")
	local version = vim.version()
	local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

	return " " .. total_plugins .. " plugins" .. nvim_version_info
end

dashboard.section.footer.val = footer()
dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

dashboard.opts.opts.noautocmd = true

local header_button_padding = 4
local occu_height = #dashboard.section.header.val + 2 * #dashboard.section.buttons.val + header_button_padding
local header_padding = math.max(0, math.ceil((vim.fn.winheight("$") - occu_height) * 0.25))
local footer_button_padding_ub = vim.o.lines - header_padding - occu_height - #dashboard.section.footer.val - 3
local footer_button_padding = math.floor((vim.fn.winheight("$") - 2 * header_padding - occu_height))
footer_button_padding = math.max(
	0,
	math.max(math.min(0, footer_button_padding), math.min(math.max(0, footer_button_padding), footer_button_padding_ub))
)
dashboard.config.layout = {
	{ type = "padding", val = header_padding },
	dashboard.section.header,
	{ type = "padding", val = header_button_padding },
	dashboard.section.buttons,
	{ type = "padding", val = footer_button_padding },
	dashboard.section.footer,
}

alpha.setup(dashboard.opts)
