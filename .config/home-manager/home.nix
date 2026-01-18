{ config, pkgs, ... }:

{
  home.username = "dismint";
  home.homeDirectory = "/home/dismint";
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    asciinema
    buf
    bun
    eza
    fish
    fzf
    gcc
    gh
    git
    gnumake
    go
    libx11
    litecli
    neovim
    nixfmt
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodejs_24
    openssh
    prettier
    python314
    ripgrep
    ruff
    shfmt
    starship
    stow
    stylua
    svg-term
    tmux
    unzip
    uv
    yazi
    zig
    zk
    zoxide

    # language servers
    gopls
    lua-language-server
    pyrefly
    svelte-language-server
    typescript-language-server
    vue-language-server
    zls
  ];

  programs.home-manager.enable = true;
}
