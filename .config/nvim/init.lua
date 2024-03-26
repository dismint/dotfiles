--| 🙑  dismint
--| YW5uaWUgPDM=

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
  -- utils
  {"neoclide/coc.nvim", branch = "release" },
  "dcampos/nvim-snippy",
  "lukas-reineke/indent-blankline.nvim",
  "terrortylor/nvim-comment",
  "tpope/vim-repeat",
  "ggandor/leap.nvim",
  "yamatsum/nvim-cursorline",
  "sainnhe/gruvbox-material",
  "nvim-lualine/lualine.nvim",
  "nvim-tree/nvim-tree.lua",
  "romgrk/barbar.nvim",
  "github/copilot.vim",
  -- languages
  {"kaarmu/typst.vim", ft = {"typst"}, lazy = false },
})

-- package setup

require("snippy").setup({
  mappings = {
    is = {
      ["<Tab>"] = "expand_or_advance",
      ["<S-Tab>"] = "previous",
    },
    nx = {
      ["<leader>x"] = "cut_text",
    },
  },
})

require("lualine").setup {
  options = { theme = "gruvbox-material" }
}

require("nvim-web-devicons").setup {
  strict = true;
}

require("nvim-cursorline").setup()
require("barbar").setup()
require("nvim-tree").setup()
require("nvim_comment").setup()
require("ibl").setup()
require("mason").setup()
require("mason-lspconfig").setup()
require("leap").add_default_mappings()
require("lspconfig").typst_lsp.setup{}

-- keybinds --

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
map("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", opts)
map("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", opts)
map("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", opts)
map("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", opts)
map("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", opts)
map("n", "<A-c>", "<Cmd>BufferClose<CR>", opts)
map("n", "<A-f>", ":call CocAction('format')<CR>", opts)
map("i", "<A-t>", "| 🙑  dismint<CR>| YW5uaWUgPDM=", opts)

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
vo.tabstop = 2
vo.shiftwidth = 2

vo.number = true
vo.relativenumber = true

vo.scrolloff = 6

vo.cursorline = true
vo.cursorcolumn = true

-- visuals

vo.guifont = "CaskaydiaCove Nerd Font Mono"

vg.gruvbox_material_background = "soft"
vg.gruvbox_material_transparent_background = "1"
vg.gruvbox_material_ui_contrast = "high"
vim.cmd([[colorscheme gruvbox-material]])
