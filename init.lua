--"vim.opt" for editor settings
--"vim.keymap" for key remaping
--"vim.g" is global? idk it has mapleader in it
--"vim.cmd" for vim editor commands
--":vsplit" to split winodw verticaly
--":terminal" to start terminal

--TODO: Figure out how to do init:ing with cli args when starting nvim
--Wanna have different setups for different languages without making it
--on attach

--TODO: Figure out how to highlight "TODO:" in comments

vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.tabstop = 8
vim.opt.softtabstop = 0
vim.opt.hlsearch = true

vim.g.mapleader = ' '

--Insert mode binds

vim.keymap.set('i', 'jj', '<Esc>')

--Normal mode binds

--Building

--For MSVC
vim.keymap.set('n', '<leader>b', function()
    vim.cmd('!build')
    end
)

--Editing
vim.keymap.set('n', '<leader>d', 'dd')
vim.keymap.set('n', '<leader>w', vim.cmd.noh)

--Diagnostics
vim.keymap.set('n', '<C-h>', vim.diagnostic.open_float)

--Project navigation
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

--Visual mode binds

--System clip windows TODO: check  if this works on Ubuntu
vim.keymap.set('v', '<leader>y', '"+y')

--Terminal binds
--Stolen from the internets TODO: Get it
--Get out of terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
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
		"craftzdog/solarized-osaka.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
                opts = {}
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

--Maybe add these to all lsp setups, need to figure out what it does first.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

--LSP Setups
local lspconfig = require("lspconfig")
lspconfig.ols.setup {}
lspconfig.clangd.setup {}
lspconfig.lua_ls.setup {
		capabilities = capabilities,
}
lspconfig.hls.setup {}
lspconfig.pyright.setup {
		capabilities = capabilities,
}
lspconfig.gopls.setup {}
lspconfig.zls.setup {}

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
                        --Disabled until I fix the indentation (change indents 2 -> 4)
			--vim.lsp.buf.format( { async = true, insert_spaces = true, tab_sizes = 4 } )
		end, opts)
	end
})

--Key binds post package setup
--Idk of this makes sense

--Telescope binds
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', function()
    builtin.find_files({no_ignore=true, no_ignore_paren=true})
end, {})
vim.keymap.set('n', '<leader>fg', function()
    builtin.live_grep({no_ignore=true, no_ignore_paren=true})
end, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

--Cmp setup yoinked from kickstart nvim
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

--Color scheme customization
require("tokyonight").setup({
	style = "moon",
	styles = {
		comments = { italic = true }
	}
})

--Color scheme Init
--vim.cmd([[colorscheme tokyonight]])
vim.cmd([[colorscheme solarized-osaka]])
