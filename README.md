<div align="center">
  
# dotfiles [![Email](https://img.shields.io/badge/EMAIL-mintjjc%40gmail.com-93BFCF?style=flat&logoSize=auto&labelColor=EEE9DA)](mailto:mintjjc@gmail.com)

[Overview](#overview) • [`nvim`](#-nvim-) • [`hyprland`](#-hyprland-)

</div>

# Overview
This is a collection of my dotfiles I use in my workflow, both on my EndeavourOS + Hyprland setup as well as WSL. Primarily for personal use but let me know if you happen to find something useful in here for yourself!

I use [GNU Stow](https://www.gnu.org/software/stow/) to manage my dotfiles on my system, as well as [Home Manager](https://github.com/nix-community/home-manager) for managing software dependencies.

# `nvim`
My configuration is contained within one file and aims to be as self contained as possible, downloading both the plugins and their manager automatically. Run `:Copilot` after initial setup to login.

# `WSL`
## Clipbaord
In order to have `nvim` work correctly with the `WSL` clipbaord, install [win32yank](https://github.com/equalsraf/win32yank) onto `WSL`

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
