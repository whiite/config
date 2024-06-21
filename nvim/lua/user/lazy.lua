local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Install your plugins here
require("lazy").setup({
	-- General --
	{ "nvim-lua/plenary.nvim" }, -- Useful lua functions used by lots of plugins
	{
		"windwp/nvim-autopairs", -- Autopairs, integrates with both cmp and treesitter
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
				ts_config = {
					lua = { "string", "source" },
					javascript = { "string", "template_string" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" }, -- find file type with: `echo &ft`
				fast_wrap = {
					map = "<M-e>", -- 'M' = modifier = alt
					chars = { "{", "[", "(", '"', "'", "`", "<" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0, -- Offset from pattern match
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})

			require("cmp").event:on(
				"confirm_done",
				require("nvim-autopairs.completion.cmp").on_confirm_done({ map_char = { tex = "" } })
			)
		end,
	},
	{
		"numToStr/Comment.nvim", -- Easily comment lines
		lazy = true,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		opts = function()
			return {
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}
		end,
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = true,
		opts = function()
			vim.g.skip_ts_context_commentstring_module = true
			return {
				enable_autocmd = false,
			}
		end,
	},
	{
		"nvim-lualine/lualine.nvim", -- Status line at the bottom of the window
		version = "*",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("user.plugins.lualine")
		end,
	},
	{
		"akinsho/bufferline.nvim", -- Pretty tab bar
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"moll/vim-bbye", -- Bbye allows you to do delete buffers (close files) without closing your windows or messing up your layout.
		},
		config = function()
			require("user.plugins.bufferline")
		end,
	},
	{
		"akinsho/toggleterm.nvim", -- Toggle terminals (float or split)
		version = "*",
		config = function()
			require("user.plugins.toggleterm")
		end,
	},
	{
		"nacro90/numb.nvim", -- Preview number lines by typing :<line-number>
		event = "CmdlineEnter",
		opts = {
			show_numbers = true, -- Enable 'number' for the window while peeking
			show_cursorline = true, -- Enable 'cursorline' for the window while peeking
			number_only = false, -- Peek only when the command is only a number instead of when it starts with a number
			centered_peeking = true, -- Peeked line will be centered relative to window
		},
	},
	{ "tpope/vim-surround", event = { "BufReadPre", "BufNewFile" } }, -- Easily modify surrounding characters
	{ "tpope/vim-sleuth", event = { "BufReadPre", "BufNewFile" } }, -- Auto detect indentation and tabstop (tab/space)
	{
		"ggandor/leap.nvim", -- Fast movement by using 's'/'S' followed by characters you wish to leap to
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("leap").add_default_mappings()
		end,
	},
	{
		"michaelrommel/nvim-silicon",
		lazy = true,
		cmd = "Silicon",
		opts = {
			font = "Fira Code=34",
			theme = "Dracula",
			background = "#333",
			no_window_controls = true,
			pad_horiz = 0,
			pad_vert = 0,
			no_round_corner = true,
			output = function()
				return "~/Downloads/" .. os.date("!%Y-%m-%dT%H-%M-%S") .. "_code_screenshot.png"
			end,
		},
	},

	-- cmp plugins
	{
		"hrsh7th/nvim-cmp", -- The completions plugin
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-buffer", -- buffer completions
			"hrsh7th/cmp-path", -- path completions
			"hrsh7th/cmp-cmdline", -- cmdline completions
			"hrsh7th/cmp-nvim-lsp", -- LSP completions
			"hrsh7th/cmp-nvim-lsp-signature-help", -- Function signature completions
			"hrsh7th/cmp-nvim-lua", -- Neovim completions for lua
			"onsails/lspkind.nvim", -- vscode-like pictograms to built-in lsp
		},
		config = function()
			require("user.plugins.cmp")
		end,
	},

	-- Prettier UI
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPre", "BufNewFile" },
		main = "ibl",
		opts = {},
		config = function()
			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowGreen",
				"RainbowViolet",
				"RainbowCyan",
			}
			local hooks = require("ibl.hooks")
			-- create the highlight groups in the highlight setup hook, so they are reset
			-- every time the colorscheme changes
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
			end)

			vim.g.rainbow_delimiters = { highlight = highlight }
			require("ibl").setup({ scope = { highlight = highlight } })

			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		end,
	}, -- Indent guides and invisible character support
	{
		"b0o/incline.nvim",
		config = function()
			require("incline").setup({
				hide = {
					cursorline = "focused_win",
				},
			})
		end,
		event = "VeryLazy",
	},
	{
		"NvChad/nvim-colorizer.lua",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			filetypes = {
				"javascript",
				"typescript",
				sass = {
					names = true,
				},
				scss = {
					names = true,
				},
				css = {
					names = true,
				},
				html = {},
				svg = {},
			},
			user_default_options = { names = false, css = true },
		},
	},
	{
		"karb94/neoscroll.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			easing = "linear", -- linear, quadratic, cubic, quartic, quintic, circular, sine
			respect_scrolloff = true,
		},
	},
	{
		"folke/which-key.nvim",
		config = function()
			require("user.plugins.whichkey")
		end,
	},
	{
		"rcarriga/nvim-notify",
		priority = 500,
		config = function()
			local notify = require("notify")
			notify.setup({
				fps = 45,
				level = "info",
				render = "compact",
			})
			vim.notify = notify
		end,
	},
	{
		"Fildo7525/pretty_hover",
		lazy = true,
		enabled = false,
		event = "LspAttach",
		config = function()
			require("pretty_hover").setup()
			vim.lsp.buf.hover = require("pretty_hover").hover
		end,
	},
	{
		"edluffy/hologram.nvim",
		ft = "md",
		opts = { auto_display = true },
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},

	-- Color schemes
	-- use("lunarvim/colorschemes") -- A bunch of color schemes to try out
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night", -- "storm" | "moon" | "night" | "day"
				styles = {
					sidebars = "dark",
				},
				lualine_bold = true,
				transparent = false,
				-- borderless telescope
				on_highlights = function(hl, c)
					local prompt = "#2d3149"
					hl.TelescopeNormal = {
						bg = c.bg_dark,
						fg = c.fg_dark,
					}
					hl.TelescopeBorder = {
						bg = c.bg_dark,
						fg = c.bg_dark,
					}
					hl.TelescopePromptNormal = {
						bg = prompt,
					}
					hl.TelescopePromptBorder = {
						bg = prompt,
						fg = prompt,
					}
					hl.TelescopePromptTitle = {
						bg = prompt,
						fg = prompt,
					}
					hl.TelescopePreviewTitle = {
						bg = c.bg_dark,
						fg = c.bg_dark,
					}
					hl.TelescopeResultsTitle = {
						bg = c.bg_dark,
						fg = c.bg_dark,
					}
				end,
			})
			require("user.utils.colorscheme").set_colorscheme("tokyonight")
		end,
	},
	{
		"catppuccin/nvim",
		lazy = true,
		enabled = false,
		config = function()
			local flavour = "macchiato" -- mocha, macchiato, frappe, latte
			require("catppuccin").setup({
				flavour = flavour, -- mocha, macchiato, frappe, latte
			})
			require("user.utils.colorscheme").set_colorscheme("catppuccin-" .. flavour)
		end,
	},

	-- Debugging
	{
		"mfussenegger/nvim-dap",
		cmd = {
			"DapToggleBreakpoint",
			"DapContinue",
			"DapToggleRepl",
			"DapStepOver",
			"DapStepInto",
			"DapStepOut",
			"DapTerminate",
		},
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		config = function()
			require("user.plugins.nvim-dap")
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		lazy = true,
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("user.plugins.nvim-dap-ui")
		end,
	},
	{
		"leoluz/nvim-dap-go",
		ft = "go",
		dependencies = { "mfussenegger/nvim-dap" },
		opt = {},
	},
	{
		"mrcjkb/rustaceanvim", -- Rust LSP and DAP support
		version = "^4",
		ft = "rust",
		config = function()
			require("user.lsp.rustaceanvim")
		end,
	},
	{
		"saecki/crates.nvim", -- Manage Rust dependencies inside Cargo.toml
		tag = "stable",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = "toml",
		config = function()
			require("crates").setup()
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim", -- fuzzy file/text finder UI
		lazy = true,
		event = { "BufReadPre", "BufNewFile" },
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			require("user.plugins.telescope")
		end,
	},

	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons", -- file icons
		},
		config = function()
			require("user.plugins.nvim-tree")
		end,
	},

	-- LSP
	{ "neovim/nvim-lspconfig", lazy = true }, -- enable LSP
	{
		"williamboman/mason.nvim",
	}, -- LSP/lint and debug manager
	{ "williamboman/mason-lspconfig.nvim" }, -- lspconfig compatibility
	{
		"nvimtools/none-ls.nvim", -- for formatters and linters
		dependencies = { "nvim-lua/plenary.nvim", "davidmh/cspell.nvim" },
	},
	{
		"folke/trouble.nvim",
		lazy = true,
		cmd = { "TroubleToggle", "TroubleClose", "TroubleRefresh", "Trouble" },
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("user.plugins.trouble")
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				"LazyVim",
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	}, -- typings for neovim within lua files
	{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			-- extensions
			"nvim-treesitter/nvim-treesitter-context",
			"JoosepAlviste/nvim-ts-context-commentstring",
			-- "nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		config = function()
			require("user.plugins.treesitter")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
			max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
			trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
			patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
				-- For all filetypes
				-- Note that setting an entry here replaces all other patterns for this entry.
				-- By setting the 'default' entry below, you can control which nodes you want to
				-- appear in the context window.
				default = {
					"class",
					"function",
					"method",
					"for",
					"while",
					"if",
					"switch",
					"case",
				},
				-- Patterns for specific filetypes
				-- If a pattern is missing, *open a PR* so everyone can benefit.
				tex = {
					"chapter",
					"section",
					"subsection",
					"subsubsection",
				},
				rust = {
					"impl_item",
					"struct",
					"enum",
				},
				scala = {
					"object_definition",
				},
				vhdl = {
					"process_statement",
					"architecture_body",
					"entity_declaration",
				},
				markdown = {
					"section",
				},
			},
			exact_patterns = {
				-- Example for a specific filetype with Lua patterns
				-- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
				-- exactly match "impl_item" only)
				-- rust = true,
			},

			-- [!] The options below are exposed but shouldn't require your attention,
			--     you can safely ignore them.

			zindex = 20, -- The Z-index of the context window
			mode = "topline", -- Line used to calculate context. Choices: 'cursor', 'topline'
			separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
		},
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")
			---@type rainbow_delimiters.config
			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
				},
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	}, -- rainbow parenthesis

	-- Git
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			watch_gitdir = {
				interval = 1000,
				follow_files = true,
			},
			attach_to_untracked = true,
			current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
				virt_text_priority = 100, -- 'eol' | 'overlay' | 'right_align'
				ignore_whitespace = false,
				delay = 500,
			},
			current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
		},
	}, -- git info in the gutter (like VSCode)
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		config = true,
	}, -- show and resolve git conflicts within files
})
