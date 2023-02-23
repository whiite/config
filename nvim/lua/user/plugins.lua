-- Automatically install packer
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end
local packer_bootstrap = ensure_packer()

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Auto command that reloads neovim whenever you save the plugins.lua file
local auto_group = "packer_user_config"
vim.api.nvim_create_augroup(auto_group, { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = auto_group,
	pattern = { "plugins.lua" },
	command = "source <afile> | PackerSync",
})

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	-- Have packer manage itself
	use("wbthomason/packer.nvim")

	-- Optimisation
	use("lewis6991/impatient.nvim") -- Speeds up lua module loading to improve startup time

	-- General --
	use("nvim-lua/popup.nvim") -- An implementation of the Popup API from vim in Neovim
	use("nvim-lua/plenary.nvim") -- Useful lua functions used by lots of plugins
	use({
		"windwp/nvim-autopairs", -- Autopairs, integrates with both cmp and treesitter
		config = function()
			require("user.plugins.autopairs")
		end,
	})
	use({
		"numToStr/Comment.nvim", -- Easily comment lines
		requires = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			require("user.plugins.comment")
		end,
	})
	use({
		"nvim-lualine/lualine.nvim", -- Status line at the bottom of the window
		requires = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("user.plugins.lualine")
		end,
	})
	use({
		"akinsho/bufferline.nvim", -- Pretty tab bar
		tag = "v2.*",
		after = { "catppuccin", "tokyonight" },
		requires = {
			"nvim-tree/nvim-web-devicons",
			"moll/vim-bbye", -- Bbye allows you to do delete buffers (close files) without closing your windows or messing up your layout.
		},
		config = function()
			require("user.plugins.bufferline")
		end,
	})
	use({
		"akinsho/toggleterm.nvim", -- Toggle terminals (float or split)
		tag = "v2.*",
		config = function()
			require("user.plugins.toggleterm")
		end,
	})
	use({
		"nacro90/numb.nvim", -- Preview number lines by typing :<line-number>
		config = function()
			require("user.plugins.numb")
		end,
	})
	use("tpope/vim-surround") -- Easily modify surrounding characters
	use("tpope/vim-sleuth") -- Auto detect indentation and tabstop (tab/space)
	use({
		"ggandor/leap.nvim", -- Fast movement by uisng 's' followed by characters you wish to leap to
		config = function()
			require("leap").add_default_mappings()
		end,
	})

	-- Debugging
	use({
		"mfussenegger/nvim-dap",
		config = function()
			require("user.plugins.nvim-dap")
		end,
	})
	use({
		"rcarriga/nvim-dap-ui",
		requires = { "mfussenegger/nvim-dap" },
		config = function()
			require("user.plugins.nvim-dap-ui")
		end,
	})
	use({
		"leoluz/nvim-dap-go",
		requires = { "mfussenegger/nvim-dap" },
		config = function()
			require("dap-go").setup()
		end,
	})

	-- Color schemes
	-- use("lunarvim/colorschemes") -- A bunch of color schemes to try out
	use({
		"folke/tokyonight.nvim",
		as = "tokyonight",
		config = function()
			require("tokyonight").setup({
				style = "storm", -- "storm" | "moon" | "night" | "day"
				styles = {
					sidebars = "dark",
				},
				lualine_bold = true,
				transparent = false,
			})
			require("user.utils.colorscheme").set_colorscheme("tokyonight")
		end,
	})
	use({
		"catppuccin/nvim",
		as = "catppuccin",
		config = function()
			local flavour = "macchiato" -- mocha, macchiato, frappe, latte
			require("catppuccin").setup({
				flavour = flavour, -- mocha, macchiato, frappe, latte
			})
			-- require("user.utils.colorscheme").set_colorscheme("catppuccin-" .. flavour)
		end,
	})

	-- Prettier UI
	use("lukas-reineke/indent-blankline.nvim") -- Indent guides and invisible character support
	use({
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("user.plugins.nvim-colorizer")
		end,
	})
	use({
		"edluffy/specs.nvim",
		config = function()
			require("user.plugins.specs")
		end,
	})
	use({
		"karb94/neoscroll.nvim",
		config = function()
			require("user.plugins.neoscroll")
		end,
	})
	use({
		"goolord/alpha-nvim", -- Dashboard on startup
		requires = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("user.plugins.alpha")
		end,
	})
	use({
		"folke/which-key.nvim",
		config = function()
			require("user.plugins.whichkey")
		end,
	})
	use({
		"rcarriga/nvim-notify",
		config = function()
			require("user.plugins.nvim-notify")
		end,
	})

	-- cmp plugins
	use({
		"hrsh7th/nvim-cmp", -- The completions plugin
		requires = {
			"hrsh7th/cmp-buffer", -- buffer completions
			"hrsh7th/cmp-path", -- path completions
			"hrsh7th/cmp-cmdline", -- cmdline completions
			"saadparwaiz1/cmp_luasnip", -- snippet completions
			"hrsh7th/cmp-nvim-lsp", -- LSP completions
			"hrsh7th/cmp-nvim-lua", -- Neovim completions for lua
			"onsails/lspkind.nvim", -- vscode-like pictograms to built-in lsp
		},
		config = function()
			require("user.plugins.cmp")
		end,
	})

	-- snippets
	use("L3MON4D3/LuaSnip") --snippet engine
	use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

	-- LSP
	use("neovim/nvim-lspconfig") -- enable LSP
	use({ "williamboman/mason.nvim" }) -- LSP/lint and debug manager
	use({ "williamboman/mason-lspconfig.nvim" }) -- lspconfig compatibility
	use({
		"jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"simrat39/rust-tools.nvim", -- Rust LSP and debug support
		config = function()
			require("user.lsp.rust-tools")
		end,
	})
	use({
		"folke/trouble.nvim",
		requires = "nvim-tree/nvim-web-devicons",
		config = function()
			require("user.plugins.trouble")
		end,
	})
	use("folke/neodev.nvim") -- lua langauge server extension for neovim config

	-- Telescope
	use({
		"nvim-telescope/telescope.nvim", -- fuzzy file/text finder UI
		after = { "catppuccin", "tokyonight" },
		requires = {
			{ "nvim-lua/plenary.nvim" },
		},
		config = function()
			require("user.plugins.telescope")
		end,
	})
	-- Telescope extensions
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({ "nvim-telescope/telescope-ui-select.nvim" })

	-- Treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
		requires = {
			-- extensions
			{
				"nvim-treesitter/nvim-treesitter-context",
				config = function()
					require("user.plugins.nvim-treesitter-context")
				end,
			},
			{ "p00f/nvim-ts-rainbow" }, -- rainbow parenthesis
			-- {"nvim-treesitter/playground"}, -- useful for creating parsers/extensions
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
		},
		config = function()
			require("user.plugins.treesitter")
		end,
	})

	-- Git
	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("user.plugins.gitsigns")
		end,
	}) -- git info in the gutter (like VSCode)

	-- File explorer
	use({
		"nvim-tree/nvim-tree.lua",
		requires = {
			"nvim-tree/nvim-web-devicons", -- file icons
		},
		config = function()
			require("user.plugins.nvim-tree")
		end,
	})

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end)
