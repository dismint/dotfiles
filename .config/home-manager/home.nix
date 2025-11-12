{ config, pkgs, ... }:

{
  home.username = "dismint";
  home.homeDirectory = "/home/dismint";
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    eza
    fish
    fzf
    gcc
    gh
    git
    gnumake
    neovim
    openssh
    ripgrep
    starship
    stow
    tmux
    unzip
    uv
    yazi
    zoxide

    # coding
    nodejs_24
    python314
    zig
  ];

  programs.home-manager.enable = true;
}
