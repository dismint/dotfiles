-- | 🙑  dismint
-- | YW5uaWUgPDM=

vim.keymap.set("i", "<C-j>", "| 🙑  dismint<CR>| YW5uaWUgPDM=")

--  SECTION: config

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
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

--  SECTION: autocmds

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

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

--  SECTION: utils

local imthemap = function(mode, keys, func, desc, opts)
	opts["desc"] = desc
	vim.keymap.set(mode, keys, func, opts)
end

imthemap("n", "<leader>oi", function()
	if vim.bo.filetype == "zig" then
		vim.lsp.buf.code_action({
			context = { only = { "source.organizeImports" }, diagnostics = {} },
			apply = true,
		})
	end
end, "[o]rganize [i]mports", {})

local attachBindings = function(bufnr, client)
	local lspmap = function(keys, func, desc)
		imthemap("n", keys, func, desc, { buffer = bufnr })
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
		lspmap("<leader>ti", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
		end, "[t]oggle [i]nlay hints")
	end
end

--  SECTION: plugins

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

			vim.g.zig_fmt_parse_errors = 0
			vim.g.zig_fmt_autosave = 0

			local servers = {
				gopls = {
					settings = {
						gopls = {
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},
				pyrefly = {},
				zls = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = { disable = { "missing-fields", "undefined-field" } },
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
				"mypy",
				"goimports",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for server_name, server_config in pairs(servers) do
				vim.lsp.enable(server_name, true)
				server_config.capabilities = capabilities
				vim.lsp.config(server_name, server_config)
			end
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = { "lua", "python", "zig", "go" },
			auto_install = true,
			highlight = {
				enable = true,
			},
			indent = { enable = true },
		},
		config = function(_, opts)
			require("nvim-treesitter.install").prefer_git = true
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

			imthemap({ "i", "s" }, "<C-l>", function()
				luasnip.jump(1)
			end, "jump 1 cmp", { silent = true })
			imthemap({ "i", "s" }, "<C-h>", function()
				luasnip.jump(-1)
			end, "jump -1 cmp", { silent = true })

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
					path_display = { "truncate", "filename_first" },
				},
			})
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local tmap = function(keys, func, desc)
				imthemap("n", keys, function()
					func({
						preview_title = "preview",
						prompt_title = desc,
					})
				end, desc, {})
			end

			local tb = require("telescope.builtin")
			tmap("<leader>lh", tb.help_tags, "[l]ind [h]elp")
			tmap("<leader>lk", tb.keymaps, "[l]ind [k]eymaps")
			tmap("<leader>lf", tb.find_files, "[l]ind [f]iles")
			tmap("<leader>ls", tb.builtin, "[l]ind [s]elect")
			tmap("<leader>lw", tb.grep_string, "[l]ind current [w]ord")
			tmap("<leader>lg", tb.live_grep, "[l]ind by [g]rep")
			tmap("<leader>ld", tb.diagnostics, "[l]ind [d]iagnostics")
			tmap("<leader>lb", tb.buffers, "[l]ind [b]uffers")

			imthemap("n", "<leader>/", function()
				tb.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 20,
					previewer = false,
					prompt_title = "find in current buffer",
				}))
			end, "fearch in current buffer", {})

			imthemap("n", "<leader>l/", function()
				tb.live_grep({
					grep_open_files = true,
					prompt_title = "find open files",
				})
			end, "[l]ind in open files", {})

			imthemap("n", "<leader>ln", function()
				tb.find_files({ cwd = vim.fn.stdpath("config"), preview_title = "preview" })
			end, "[l]ind [n]eovim files", {})
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
				go = { "goimports" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
			},
			format_on_save = {
				timeout_ms = 5000,
			},
		},
		config = function(_, opts)
			local conform = require("conform")
			conform.setup(opts)

			imthemap("n", "<leader>fm", conform.format, "[f]or[m]at", {})

			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.py,*.lua,*.zig,*.js,*.ts,*.json,*.html,*.css,*.go",
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
				STEP = { icon = "P", color = "hint" },
				TODO = { icon = "T", color = "info" },
			},
			highlight = {
				pattern = { [[.*<(KEYWORDS)\s*\d+\s*:]], [[.*<(KEYWORDS)\s*:]] },
			},
		},
		config = function(_, opts)
			require("todo-comments").setup(opts)
		end,
		imthemap("n", "<leader>lt", ":TodoTelescope<CR>", "[l]ind [t]odos", {}),
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
				lualine_c = {
					"filename",
					{
						function()
							local cur_buf = vim.api.nvim_get_current_buf()
							return require("hbac.state").is_pinned(cur_buf) and "󰐃" or "󰤱"
						end,
						color = { fg = "#ef5f6b", gui = "bold" },
					},
				},
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
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					keymap = {
						next = "<M-f>",
						prev = "<M-g>",
						accept = "<M-o>",
					},
				},
			})
		end,
	},
	{
		"mikavilpas/yazi.nvim",
		version = "v11.10.2",
		event = "VeryLazy",
		dependencies = {
			"folke/snacks.nvim",
			{ "nvim-lua/plenary.nvim", lazy = true },
		},
		keys = {
			{
				"<leader>dy",
				"<cmd>Yazi cwd<CR>",
				{ "n", "v" },
				"open [y]azi at the current working [d]irectory",
			},
			{
				"<leader>fy",
				"<cmd>Yazi<CR>",
				{ "n", "v" },
				"open [y]azi at the current [f]ile",
			},
			{
				"<leader>y",
				"<cmd>Yazi toggle<CR>",
				{ "n", "v" },
				"open last [y]azi session",
			},
		},
		opts = {
			open_for_directories = true,
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				presets = {
					bottom_search = false,
					command_palette = true,
					long_message_to_split = true,
					inc_rename = false,
					lsp_doc_border = true,
				},
			})
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@diagnostic disable-next-line: undefined-doc-name
		---@type snacks.Config
		opts = {
			git = { enabled = false },
			bigfile = { enabled = true },
			dashboard = { enabled = true },
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
	{
		"axkirillov/hbac.nvim",
		lazy = false,
		config = function()
			local actions = require("hbac.telescope.actions")
			require("telescope").load_extension("hbac")

			require("hbac").setup({
				autoclose = true,
				threshold = 10,
				close_command = function(bufnr)
					vim.api.nvim_buf_delete(bufnr, {})
				end,
				close_buffers_with_windows = false,
				telescope = {
					sort_mru = true,
					sort_lastused = true,
					selection_strategy = "row",
					use_default_mappings = true,
					mappings = {
						i = {
							["<M-c>"] = actions.close_unpinned,
							["<M-x>"] = actions.delete_buffer,
							["<M-a>"] = actions.pin_all,
							["<M-u>"] = actions.unpin_all,
							["<M-y>"] = actions.toggle_pin,
						},
						n = {},
					},
					pin_icons = {
						pinned = { "󰐃 ", hl = "DiagnosticOk" },
						unpinned = { "󰤱 ", hl = "DiagnosticOk" },
					},
				},
			})
		end,
		keys = {
			{
				"<leader>th",
				function()
					require("telescope").extensions.hbac.buffers()
				end,
				desc = "[t]elescope [h]bac",
			},
			{
				"<leader>ht",
				function()
					require("hbac").toggle_pin()
				end,
				desc = "[h]bac [t]oggle",
			},
			{
				"<leader>hc",
				function()
					require("hbac").close_unpinned()
				end,
				desc = "[h]bac [c]lose",
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
				python = { "mypy" },
			}
		end,
	},
	{ "kevinhwang91/nvim-bqf", ft = "qf" },
	{ "dstein64/nvim-scrollview", opts = {} },
	{ "brenoprata10/nvim-highlight-colors", opts = {} },
	{ "lewis6991/gitsigns.nvim", opts = {} },
	"tpope/vim-fugitive",
	"mbbill/undotree",
})
