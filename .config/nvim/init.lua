-- | 🙑  dismint
-- | YW5uaWUgPDM=

vim.keymap.set("i", "<C-j>", "| 🙑  dismint<CR>| YW5uaWUgPDM=")

-- SECTION: config

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true

vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.showmode = false
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.colorcolumn = "80"
vim.opt.scrolloff = 10

vim.opt.updatetime = 250
vim.opt.timeoutlen = 500
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.g.have_nerd_font = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- SECTION: autocmds

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		vim.opt.relativenumber = false
	end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		vim.opt.relativenumber = true
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.tex",
	callback = function()
		vim.bo.filetype = "tex"
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- SECTION: utils

local nomap = function(keys, func, desc, opts)
	opts["desc"] = desc
	vim.keymap.set("n", keys, func, opts)
end

local nmap = function(keys, func, desc)
	nomap(keys, func, desc, {})
end

local attachBindings = function(bufnr, client)
	local lspmap = function(keys, func, desc)
		nomap(keys, func, desc, { buffer = bufnr })
	end

	local tb = require("telescope.builtin")
	lspmap("gd", tb.lsp_definitions, "[g]oto [d]efinition") -- <C-t> jumps back
	lspmap("gD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
	lspmap("gr", tb.lsp_references, "[g]oto [r]eferences")
	lspmap("gI", tb.lsp_implementations, "[g]oto [I]mplementation")
	lspmap("<leader>td", tb.lsp_type_definitions, "[t]ype [d]efinition")
	lspmap("<leader>ds", tb.lsp_document_symbols, "[d]ocument [s]ymbols")
	lspmap("<leader>ws", tb.lsp_dynamic_workspace_symbols, "[w]work [s]ymbols")

	lspmap("<leader>rn", vim.lsp.buf.rename, "[r]e[n]ame")
	lspmap("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")
	lspmap("K", vim.lsp.buf.hover, "hover lsp documentation")
	lspmap("<leader>hd", vim.diagnostic.open_float, "[h]over [d]iagnostic")

	if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
		lspmap("<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
		end, "[t]oggle inlay [h]ints")
	end
end

-- SECTION: plugins

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "williamboman/mason.nvim", opts = {} },
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					attachBindings(event.buf, client)
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- set vars

			vim.g.zig_fmt_parse_errors = 0
			vim.g.zig_fmt_autosave = 0

			local servers = {
				basedpyright = {},
				zls = {
					root_dir = function(fname)
						return require("lspconfig").util.root_pattern(".git")(fname) or vim.loop.os_homedir()
					end,
				},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = { disable = { "missing-fields" } },
						},
					},
				},
			}

			require("mason").setup()
			local ensure_installed = vim.tbl_keys(servers)
			vim.list_extend(ensure_installed, {
				"stylua",
				"black",
				"prettier",
			})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = { "lua", "python", "zig" },
			auto_install = true,
			highlight = {
				enable = true,
			},
			indent = { enable = true },
		},
		config = function(_, opts)
			require("nvim-treesitter.install").prefer_git = true
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "VimEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = "make install_jsregexp",
			},
			"saadparwaiz1/cmp_luasnip",
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_snipmate").lazy_load()
			luasnip.config.setup()

			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				luasnip.jump(1)
			end, { silent = true })

			vim.keymap.set({ "i", "s" }, "<C-h>", function()
				luasnip.jump(-1)
			end, { silent = true })

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete({}),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "cmdline" },
					{ name = "lazydev", group_index = 0 },
					{ name = "path" },
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
			})
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			local actions = require("telescope.actions")
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
				defaults = {
					initial_mode = "normal",
					results_title = "results",
					mappings = {
						n = { ["d"] = actions.delete_buffer },
						i = {},
					},
				},
			})
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local tmap = function(keys, func, desc)
				nmap(keys, function()
					func({
						preview_title = "preview",
						prompt_title = desc,
					})
				end, desc)
			end

			local tb = require("telescope.builtin")
			tmap("<leader>fh", tb.help_tags, "[f]ind [h]elp")
			tmap("<leader>fk", tb.keymaps, "[f]ind [k]eymaps")
			tmap("<leader>ff", tb.find_files, "[f]ind [f]iles")
			tmap("<leader>fs", tb.builtin, "[f]ind [s]elect")
			tmap("<leader>fw", tb.grep_string, "[f]ind current [w]ord")
			tmap("<leader>fg", tb.live_grep, "[f]ind by [g]rep")
			tmap("<leader>fd", tb.diagnostics, "[f]ind [d]iagnostics")
			tmap("<leader>fr", tb.resume, "[f]ind [r]esume")
			tmap("<leader>fc", tb.oldfiles, "[f]ind re[c]ent files")
			tmap("<leader>fb", tb.buffers, "[f]ind [b]uffers")

			nmap("<leader>/", function()
				tb.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 20,
					previewer = false,
					prompt_title = "find in current buffer",
				}))
			end, "fearch in current buffer")

			nmap("<leader>f/", function()
				tb.live_grep({
					grep_open_files = true,
					prompt_title = "[f]ind open files",
				})
			end, "[f]ind in open files")

			nmap("<leader>fn", function()
				tb.find_files({ cwd = vim.fn.stdpath("config"), preview_title = "preview" })
			end, "[f]ind [n]eovim files")
		end,
	},
	{
		"stevearc/conform.nvim",
		event = "VimEnter",
		lazy = false,
		keys = {
			{
				"<leader>tf",
				function()
					if vim.b.disable_autoformat then
						vim.cmd("FormatEnable")
						vim.notify("enabled autoformat for current buffer")
					else
						vim.cmd("FormatDisable!")
						vim.notify("disabled autoformat for current buffer")
					end
				end,
				desc = "toggle autoformat for current buffer",
			},
			{
				"<leader>tF",
				function()
					if vim.g.disable_autoformat then
						vim.cmd("FormatEnable")
						vim.notify("enabled autoformat globally")
					else
						vim.cmd("FormatDisable")
						vim.notify("disabled autoformat globally")
					end
				end,
				desc = "Toggle autoformat globally",
			},
		},
		opts = {
			notify_on_error = false,
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				zig = { "zigfmt" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
			},
		},
		config = function(_, opts)
			local conform = require("conform")
			conform.setup(opts)

			nmap("<leader>fm", conform.format, "[f]or[m]at")

			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.py,*.lua,*.zig,*.js,*.ts,*.json,*.html,*.css",
				callback = function(args)
					conform.format({ bufnr = args.buf })
				end,
			})
			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "disable autoformat-on-save",
				bang = true,
			})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "re-enable autoformat-on-save",
			})
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {},
	},
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
			keywords = {
				SECTION = { icon = "S", color = "info" },
				TODO = { icon = "T", color = "info" },
			},
		},
		config = function(_, opts)
			require("todo-comments").setup(opts)
		end,

		nmap("<leader>ft", ":TodoTelescope<CR>", "[f]ind [t]odos"),
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		config = function()
			vim.cmd("colorscheme kanagawa-dragon")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		opts = {
			options = {
				icons_enabled = vim.g.have_nerd_font,
				theme = "auto",
			},
			sections = {
				lualine_a = {
					"mode",
				},
				lualine_b = {
					"location",
					{
						"diagnostics",
						sources = { "nvim_lsp" },
						symbols = {
							error = " ",
							warn = " ",
							info = "󰋼 ",
							hint = " ",
						},
					},
					{
						"searchcount",
						maxcount = 999,
						timeout = 500,
					},
				},
				lualine_c = { "filename" },
				lualine_x = { "diff" },
				lualine_y = { "branch" },
				lualine_z = { "progress" },
			},
		},
	},
	{
		"ggandor/leap.nvim",
		config = function()
			local leap = require("leap")
			leap.add_default_mappings()
			leap.opts.case_sensitive = true
		end,
	},
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					keymap = {
						next = "<M-f>",
						prev = "<M-g>",
						accept = "<M-CR>",
					},
				},
			})
		end,
	},
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		dependencies = {
			"folke/snacks.nvim",
		},
		keys = {
			{
				"<leader>fy",
				mode = { "n", "v" },
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				"<leader>dy",
				"<cmd>Yazi cwd<cr>",
				desc = "Open the file manager in nvim's working directory",
			},
			{
				"<leader>y",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			dashboard = { enabled = true },
			explorer = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			picker = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
	},
	{ "dstein64/nvim-scrollview", opts = {} },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	{ "brenoprata10/nvim-highlight-colors", opts = {} },
	{ "lewis6991/gitsigns.nvim", opts = {} },
	"mbbill/undotree",
})
