{
  config,
  pkgs,
  pkgs-stable,
  awww,
  qml-niri,
  ...
}:

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
    btop
    buf
    bun
    claude-code
    dm-sans
    eza
    fastfetch
    ffmpeg
    fish
    fzf
    gcc
    geist-font
    gh
    git
    gnumake
    go
    google-chrome
    gopls
    grim
    kdlfmt
    libx11
    litecli
    lmstudio
    lua-language-server
    neovim
    nixfmt
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodejs_24
    openssh
    pastel
    prettier
    pyrefly
    python314
    qt6.qtdeclarative
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

    mgba

    awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    qml-niri.packages.${pkgs.stdenv.hostPlatform.system}.default
    qml-niri.packages.${pkgs.stdenv.hostPlatform.system}.quickshell
  ];

  programs.home-manager.enable = true;
}
