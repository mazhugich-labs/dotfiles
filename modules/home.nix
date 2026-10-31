{
  config,
  pkgs,
  settings,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  home.username = settings.username;
  home.homeDirectory = "/home/${settings.username}";
  home.stateVersion = settings.homeStateVersion;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Daily tools.
    codex
    herdr
    wezterm
    # Utilities used by the shell, editor, agents and maintenance scripts.
    curl
    fd
    fzf
    git
    jq
    lazygit
    neovim
    ripgrep
    shellcheck

    nerd-fonts.hack
  ];

  fonts.fontconfig.enable = true;

  home.sessionPath = [ "$HOME/.local/bin" ];
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    HERMES_HOME = "$HOME/.hermes";
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.home.homeDirectory}/.config/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      bindkey '^F' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      status = "git status";
      commit = "git commit -m";
      main = "git switch main";
      cdx = "codex --dangerously-bypass-approvals-and-sandbox";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # These are out-of-store links: the repository stays the editable source of
  # truth and application changes are immediately visible in Git.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr/config.toml";
}
