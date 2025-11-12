{ config, pkgs, ... }:

{
  home.username = "dismint";
  home.homeDirectory = "/home/dismint";
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    eza
    fish
    fzf
    gh
    git
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

    # mason
    lua-language-server
    nixfmt
    prettier
    pyrefly
    ruff
    stylua
    zls

    # languages
    gcc
    gnumake
    nodejs_24
    python314
    zig
  ];

  programs.home-manager.enable = true;
}
