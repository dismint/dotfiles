-- dismintjjc nvim.lua --

-- packer.nvim setup --

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- coc, unstall coc-go, coc-pyright
  use {'neoclide/coc.nvim', branch = 'release'}
  -- utils
  use 'dcampos/nvim-snippy'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'terrortylor/nvim-comment'
  use 'tpope/vim-repeat'
  use 'ggandor/leap.nvim'
  use 'nvim-tree/nvim-web-devicons'
  use 'lewis6991/gitsigns.nvim'
  use 'nvim-lua/plenary.nvim'
  -- ui + useful
  use 'yamatsum/nvim-cursorline'
  use 'sainnhe/gruvbox-material'
  use 'nvim-lualine/lualine.nvim'
  use 'nvim-tree/nvim-tree.lua'
  use 'romgrk/barbar.nvim'
  -- typst
  use {'kaarmu/typst.vim', ft = {'typst'}}

  -- autoinstall
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- packages that actually need setup

require('snippy').setup({
  mappings = {
    is = {
      ['<Tab>'] = 'expand_or_advance',
      ['<S-Tab>'] = 'previous',
    },
    nx = {
      ['<leader>x'] = 'cut_text',
    },
  },
})
require('lualine').setup {
  options = { theme = 'gruvbox-material' }
}
require('leap').add_default_mappings()
require'nvim-web-devicons'.setup {
  strict = true;
   override_by_extension = {
  ['df'] = {
    color = '#5fd7d7',
    cterm_color = '80',
    icon = '',
    name = 'DF'
  }
 };
}

-- packages that need to be started

require('nvim-cursorline').setup()
require('barbar').setup()
require('nvim-tree').setup()
require('nvim_comment').setup()
require("ibl").setup()

-- keybinds --

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', 'cid', [[:<C-u>normal! f$vf$a<CR>]], opts)

map('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)

-- configuration --

local vo = vim.o
local vg = vim.g

-- vg.markdown_recommended_style = 0
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

-- vo.cursorline = true
-- vo.cursorcolumn = true

vo.guifont = "CaskaydiaCove Nerd Font Mono"

vg.gruvbox_material_background = 'soft'
vg.gruvbox_material_transparent_background = '1'
vg.gruvbox_material_ui_contrast = 'high'
vim.cmd([[colorscheme gruvbox-material]])
