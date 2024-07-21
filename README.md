<div align="center">
  
# dotfiles [![Email](https://img.shields.io/badge/EMAIL-mintjjc%40gmail.com-93BFCF?style=flat&logoSize=auto&labelColor=EEE9DA)](mailto:mintjjc@gmail.com)

</div>

# Overview

This is a collection of my dotfiles and other configuration files I use in various parts of my EndeavourOS + Hyprland setup. Primarily for personal use but let me know if you happen to find something useful in here for yourself!

I traditionally use [GNU Stow](https://www.gnu.org/software/stow/) to manage my dotfiles.

# `nvim`

My configuration is contained within one file and aims to be as self contained as possible, downloading both the plugins and their manager automatically.

## Dependencies

- `nodejs` for some language servers
- `ripgrep` for better grep

# Post Setup
- `:Copilot`

# `fish`

To complete the setup, installer [fisher](https://github.com/jorgebucaran/fisher), which can then be used to install [tide](https://github.com/IlanCosman/tide). My tide setup is as follows:

`tide configure --auto --style=Classic --prompt_colors='True color' --classic_prompt_color=Light --show_time='12-hour format' --classic_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Solid --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons='Many icons' --transient=Yes`
