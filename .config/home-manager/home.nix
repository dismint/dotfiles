{ config, pkgs, ... }:

{
  home.username = "dismint";
  home.homeDirectory = "/home/dismint";

  home.stateVersion = "25.05";

  home.packages = [
    # utilities
    pkgs.gh
    pkgs.git
    pkgs.neovim
    pkgs.tmux
    pkgs.ripgrep
    pkgs.yazi
    pkgs.starship
    pkgs.eza
    pkgs.fish
    pkgs.zoxide
    pkgs.stow
    pkgs.unzip
    pkgs.fzf
    pkgs.openssh
    pkgs.uv

    # coding
    pkgs.nodejs_24
    pkgs.python314
    pkgs.zig
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  # ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dismint/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = { EDITOR = "nvim"; };

  programs.home-manager.enable = true;
}
