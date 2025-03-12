<div align="center">
  
# dotfiles [![Email](https://img.shields.io/badge/EMAIL-mintjjc%40gmail.com-93BFCF?style=flat&logoSize=auto&labelColor=EEE9DA)](mailto:mintjjc@gmail.com)

[Overview](#overview) • [`nvim`](#-nvim-) • [`hyprland`](#-hyprland-)

</div>

# Overview
This is a collection of my dotfiles and other configuration files I use in various parts of my EndeavourOS + Hyprland setup. Primarily for personal use but let me know if you happen to find something useful in here for yourself!

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage my dotfiles on my system.

# `nvim`
My configuration is contained within one file and aims to be as self contained as possible, downloading both the plugins and their manager automatically.

## Dependencies
- `npm` for some language servers, will install `nodejs` as a dependency automatically
- `ripgrep` for better grep

## Post Setup
- `:Copilot`

# `hyprland`
## System Setup

- `xdg-desktop-portal-hyprland`
- `hyprpolkitagent` hyprland native polkit
- `qt5/6-wayland`

## Utilities
- `grim`, `slurp`, `wl-clipboard` for clipboard and screenshot functionality
- `rofi` for application launcher
- `spotify-launcher`
- `cava`

## Cursor
Install `hyprcursor` and `bibata-cursor-theme`. In addition to the config in `hyprland.conf`, the file `default/index.theme` in `~/.icons`, `~/.local/share/icons`, and `/usr/share/icons` should be changed to `Bibata-Cursor-Theme`
