--| 🙑  dismint
--| YW5uaWUgPDM=

-- disable netrw for nvim-tree

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- lazy loading

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
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
  -- background
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",
  "lewis6991/gitsigns.nvim",
  "nvim-treesitter/nvim-treesitter",
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "stevearc/dressing.nvim",
  -- utils
  "dcampos/nvim-snippy",
  "dcampos/cmp-snippy",
  "lukas-reineke/indent-blankline.nvim",
  "terrortylor/nvim-comment",
  "tpope/vim-repeat",
  "ggandor/leap.nvim",
  "yamatsum/nvim-cursorline",
  "nvim-lualine/lualine.nvim",
  "nvim-tree/nvim-tree.lua",
  "github/copilot.vim",
  "dstein64/nvim-scrollview",
  "fnune/recall.nvim",
  "kylechui/nvim-surround",
  "mhartington/formatter.nvim",
  "lewis6991/gitsigns.nvim",
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = "nvim-lua/plenary.nvim"
  },
  {
    "nanozuki/tabby.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      -- configs...
    end,
  },
  -- completion
  "hrsh7th/nvim-cmp",
  -- completion sources
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lua",
  "hrsh7th/cmp-nvim-lsp-signature-help",
  "hrsh7th/cmp-vsnip",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-buffer",
  "hrsh7th/vim-vsnip",
  -- languages
  { "kaarmu/typst.vim",  ft = { "typst" }, lazy = false },
  { "folke/neodev.nvim", opts = {} },
  "mrcjkb/rustaceanvim",
  -- colorschemes
  "rebelot/kanagawa.nvim",
  "sainnhe/everforest",
})

-- package setup

require("snippy").setup({
  mappings = {
    is = {
      ["<S-Tab>"] = "expand_or_advance",
      -- ["<S-Tab>"] = "previous",
    },
    nx = {
      ["<leader>x"] = "cut_text",
    },
  },
})

require("cmp").setup({
  snippet = {
    expand = function(args)
      require("snippy").expand_snippet(args.body)
    end,
  },
  mapping = {
    ["<A-k>"] = require("cmp").mapping.select_prev_item(),
    ["<A-j>"] = require("cmp").mapping.select_next_item(),
    ["<A-Space>"] = require("cmp").mapping.complete(),
    ["<A-q>"] = require("cmp").mapping.close(),
    ["<CR>"] = require("cmp").mapping.confirm({
      behavior = require("cmp").ConfirmBehavior.Insert,
      select = true,
    }),
  },
  sources = {
    { name = "snippy" },
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "buffer" },
    { name = "path" },
  },
})

require("lualine").setup {
  extensions = { "nvim-tree" },
  options = {
    theme = "material",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        symbols = {
          error = " ",
          warn = " ",
          info = "󰋼 ",
          hint = " "
        },
      },
    },
    lualine_c = { "filename" },
    lualine_x = { "selectioncount" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        symbols = {
          error = " ",
          warn = " ",
          info = "󰋼 ",
          hint = " "
        },
      },
    },
    lualine_c = { "filename" },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  }
}

require("nvim-web-devicons").setup {
  strict = true,
}

require("kanagawa").setup({
  -- transparent = true,
})

require("nvim-tree").setup {
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
}

require("nvim-treesitter.configs").setup {
  ensure_installed = { "python", "go", "rust", "lua", "cpp" },
  highlight = {
    enable = true,
  },
}

require("ibl").setup {
  scope = {
    show_start = false,
    show_end = false,
  }
}

require("tabby.tabline").use_preset("active_wins_at_tail", {
  nerdfont = true,
  lualine_theme = "material",
  tab_name = {
    name_fallback = function(_)
      return ""
    end,
  },
  buf_name = {
    mode = "shorten",
  },

})

require("telescope").setup {
  defaults = {
    initial_mode = "normal",
  },
}

require("formatter").setup {
  filetype = {
    python = {
      require("formatter.filetypes.python").autopep8,
    },
  }
}

require("nvim_comment").setup()
require("mason").setup()
require("mason-lspconfig").setup()
require("leap").add_default_mappings()
require("nvim-cursorline").setup()
require("gitsigns").setup()
require("recall").setup()
require("nvim-surround").setup()

require("lspconfig").typst_lsp.setup {}
require("lspconfig").pyright.setup {}
require("lspconfig").gopls.setup {}
require("lspconfig").lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        disable = { "missing-fields" },
      },
    },
  }
}
vim.g.rustaceanvim = {
  server = {}
}

-- keybinds --

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>ee", ":NvimTreeToggle<CR>", opts)
map("n", "<A-c>", ":bd<CR>", opts)
map("i", "<A-t>", "| 🙑  dismint<CR>| YW5uaWUgPDM=", opts)
map("n", "<A-h>", vim.diagnostic.open_float, opts)
map("n", "<A-e>", vim.lsp.buf.hover, opts)
map("n", "<A-f>", ":Format<CR>", opts)
map("n", ",", "@@", opts)

map("n", "<A-1>", "1gt", opts)
map("n", "<A-2>", "2gt", opts)
map("n", "<A-3>", "3gt", opts)
map("n", "<A-4>", "4gt", opts)
map("n", "<A-5>", "5gt", opts)

map("n", "<A-m>", "ml", opts)
map("n", "<A-M>", "'l", opts)

local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files, opts)
map("n", "<leader>fg", builtin.live_grep, opts)
map("n", "<leader>fb", builtin.buffers, opts)
map("n", "<leader>fh", builtin.help_tags, opts)
map("n", "<leader>fd", builtin.diagnostics, opts)
map("n", "<leader>fr", ":Telescope recall<CR>", opts)

-- configuration --

local vo = vim.o
local vg = vim.g

vg.vim_markdown_math = 1
vg.vim_markdown_folding_disabled = 1
vg.vim_markdown_conceal = 0
vg.tex_conceal = ""

-- typst
vg.typst_cmd = "typst"
vg.typst_pdf_viewer = "zathura"

vo.expandtab = true
vo.smartindent = true
vo.autoindent = true
-- vo.tabstop = 2
-- vo.shiftwidth = 2

vo.number = true
vo.relativenumber = true

vo.scrolloff = 6

vo.cursorline = true
vo.cursorcolumn = true

vo.clipboard = "unnamedplus"
vo.showtabline = 2

-- visuals

vo.termguicolors = true
vo.guifont = "CaskaydiaCove Nerd Font Mono"
vg.everforest_background = "hard"
vo.background = "dark"
vim.cmd([[colorscheme kanagawa-dragon]])

-- scripts

local function smart_gd()
  local clients = vim.lsp.get_active_clients()
  if next(clients) ~= nil then
    vim.lsp.buf.definition()
  else
    vim.cmd('normal! gd')
  end
end
map('n', 'gd', smart_gd, opts)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format { async = false }
  end
})

-- local function is_modified_buffer_open(buffers)
--   for _, v in pairs(buffers) do
--     if v.name:match("NvimTree_") == nil then
--       return true
--     end
--   end
--   return false
-- end
--
-- vim.api.nvim_create_autocmd("BufEnter", {
--   nested = true,
--   callback = function()
--     if
--       #vim.api.nvim_list_wins() == 1
--       and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil
--       and is_modified_buffer_open(vim.fn.getbufinfo({ bufmodified = 1 })) == false
--     then
--       vim.cmd("quit")
--     end
--   end,
-- })
