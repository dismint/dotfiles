{ config, pkgs, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
  home.username = "dismint";
  home.homeDirectory = "/home/dismint";
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    asciinema
    buf
    bun
    discord
    eza
    fish
    fzf
    gcc
    gh
    git
    gnumake
    go
    google-chrome
    gopls
    libx11
    litecli
    lua-language-server
    neovim
    nixfmt
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodejs_24
    openssh
    prettier
    pyrefly
    python314
    quickshell
    ripgrep
    ruff
    shfmt
    starship
    stow
    stylua
    svelte-language-server
    svg-term
    tmux
    typescript-language-server
    unzip
    uv
    vesktop
    vue-language-server
    yazi
    zig
    zk
    zls
    zoxide
  ];

  programs.home-manager.enable = true;
}
