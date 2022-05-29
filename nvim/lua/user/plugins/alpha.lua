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
dashboard.section.header.val = aperture
dashboard.section.buttons.val = {
	dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
	dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("p", "  Find project", ":Telescope projects <CR>"),
	dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
	dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
	dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
	dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
}

local function footer()
	-- NOTE: requires the fortune-mod package to work
	-- local handle = io.popen("fortune")
	-- local fortune = handle:read("*a")
	-- handle:close()
	-- return fortune
	return "whiite"
end

dashboard.section.footer.val = footer()

dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

dashboard.opts.opts.noautocmd = true
-- vim.cmd([[autocmd User AlphaReady echo 'ready']])
alpha.setup(dashboard.opts)
