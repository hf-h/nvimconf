--"vim.opt" for editor settings
--"vim.keymap" for key remaping
--"vim.g" is global? idk it has mapleader in it
--"vim.cmd" for vim editor commands

--local custom = require("custom")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.tabstop = 2
vim.opt.shiftwidth = 4

vim.g.mapleader = ' '

--Insert mode binds

vim.keymap.set('i', 'jj', '<Esc>')

--Normal mode binds

--Editing
vim.keymap.set('n', '<leader>d', 'dd')

--Project navigation
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

--Terminal binds
--Stolen from the internets TODO: Get it
--Get out of terminal
vim.keymap.set('t', '<C-w>h', "<C-\\><C-n><C-w>h",{silent = true})

--The package manager "Lazy"
--If the path doesnt excist clone the lazy repo
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
--Slap the path into the run time path
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	--Color theme
	{
		"folke/tokyonight.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "c", "lua", "vim", "vimdoc" },
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end
	},
	--Tree sitter
	{
		{
			'nvim-telescope/telescope.nvim',
			tag = '0.1.3',
			dependencies = { 'nvim-lua/plenary.nvim' }
		}
	},
	--Language server installer / manager
	{
		"williamboman/mason.nvim"
	},
	--Neovim lsp stuff
	{
		"neovim/nvim-lspconfig"
	},
	{
		-- Autocompletion
		'hrsh7th/nvim-cmp',
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',

			-- Adds LSP completion capabilities
			'hrsh7th/cmp-nvim-lsp',

			-- Adds a number of user-friendly snippets
			'rafamadriz/friendly-snippets',
		}
	}
})

require("mason").setup()

--LSP Setups
local lspconfig = require("lspconfig")
lspconfig.ols.setup {}
lspconfig.clangd.setup {}
lspconfig.lua_ls.setup {}
lspconfig.hls.setup {}

--LSP Key binds
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		--Jupp, that some magical bs for sure
		--Enables outocomplete?
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		--Local bindings to the buffer we are attaching to
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end
})

--Key binds post package setup
--Idk of this makes sense

--Telescope binds
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

--Color scheme customization
require("tokyonight").setup({
	style = "moon",
	styles = {
		comments = { italic = true }
	}
})

--Color scheme Init
vim.cmd([[colorscheme tokyonight]])
