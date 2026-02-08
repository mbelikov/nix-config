# ============================================================================
# home/default.nix - Home Manager Configuration
# ============================================================================
#
# This file manages user-level configuration including:
# - User packages (tools installed for your user only)
# - Dotfiles (.zshrc, .gitconfig, etc.)
# - Shell configuration
# - User-specific programs
#
# Home Manager allows you to manage your dotfiles declaratively!
# Instead of scattered files in ~/, everything is version-controlled here.
#
# IMPORTANT: Change "mikhailbelikov" in flake.nix to match your username
#
# ============================================================================

{ config, pkgs, userConfig, lib, ... }:

{
  # ==========================================================================
  # HOME MANAGER SETTINGS
  # ==========================================================================
  
  # Home Manager version - should match your system
  # This rarely needs to change
  home.stateVersion = "24.05";
  
  # User information from user-config.nix
  home.homeDirectory = "/Users/${userConfig.user.username}";
  home.username = userConfig.user.username;

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "terraform"
    ];
  };

  # ==========================================================================
  # USER PACKAGES
  # ==========================================================================
  # Packages installed for your user (not system-wide)
  #
  # HOW TO FIND PACKAGES:
  # - Search: https://search.nixos.org/packages
  # - Command: nix search nixpkgs <package-name>
  #
  # WHEN TO USE home.packages vs environment.systemPackages:
  # - home.packages: User-specific tools, development tools
  # - environment.systemPackages: System tools, shared tools
  
  home.packages = with pkgs; [
    # Development tools
    kubectl         # Kubernetes CLI
    kubernetes-helm # Helm package manager for Kubernetes
    k9s            # Kubernetes TUI
    terraform      # Infrastructure as Code
    kind           # Kubernetes in Docker
    
    # Shell utilities
    # fzf          # Fuzzy finder (installed via Homebrew)
    ripgrep        # Fast grep alternative (rg)
    fd             # Fast find alternative
    bat            # Cat with syntax highlighting
    eza            # Modern ls replacement
    
    # Network tools
    # mole is installed via Homebrew
    
    # File managers
    # far2l is installed via Homebrew
    
    # System monitoring
    # htop is in system packages
    # mactop is installed via Homebrew
    
    # Development environments
    # coursier will be installed separately
    # nvm will be managed via shell configuration
    
    # Compression tools
    unzip
    zip
    
    # JSON/YAML tools
    # jq is in system packages
    yq-go          # YAML processor
    
    # Git tools
    gh             # GitHub CLI
    git-lfs        # Git Large File Storage
  ];

  # ==========================================================================
  # PROGRAMS - Declarative Program Configuration
  # ==========================================================================
  # Home Manager can configure many programs declaratively
  # This is better than manual dotfiles because:
  # - Type-safe configuration
  # - Documentation via options
  # - Easier to share/reuse
  
  # --------------------------------------------------------------------------
  # GIT CONFIGURATION
  # --------------------------------------------------------------------------
  programs.git = {
    enable = true;
    
    # Enable Git LFS (Large File Storage)
    # Useful for storing large binary files efficiently
    lfs.enable = true;
    
    # Default git identity from user-config.nix
    userName = userConfig.user.name;
    userEmail = userConfig.user.email;

    
    # Git aliases for common commands
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --graph --oneline --all";
    };
    
    # Extra git configuration
    extraConfig = {
      # Default branch name for new repositories
      init.defaultBranch = "main";
      
      # Don't rebase when pulling
      pull.rebase = false;
      
      # Default editor for commit messages
      core.editor = "vim";
      
      # Line ending handling for cross-platform compatibility
      # "input" = Convert CRLF to LF on commit, but don't convert on checkout
      # Good for macOS/Linux users collaborating with Windows users
      core.autocrlf = "input";
      
      # Better diff algorithm
      diff.algorithm = "histogram";
      
      # Reuse recorded resolution of conflicted merges
      rerere.enabled = true;
      
      # ======================================================================
      # CONDITIONAL INCLUDES - Directory-Based Git Identities
      # ======================================================================
      # Automatically use different git configs based on project directory
      # Directories are configured in user-config.nix
      #
      # SETUP:
      # 1. Directories are created based on user-config.nix settings
      # 2. Email addresses are set in user-config.nix
      # 3. Clone personal projects to ~/${userConfig.directories.development}/${userConfig.directories.private}/
      # 4. Clone work projects to ~/${userConfig.directories.development}/${userConfig.directories.work}/
      #
      # VERIFY:
      # cd ~/${userConfig.directories.development}/${userConfig.directories.private}/some-project && git config user.email
      # cd ~/${userConfig.directories.development}/${userConfig.directories.work}/some-project && git config user.email
      
      # Personal/private projects
      includeIf."gitdir:~/${userConfig.directories.development}/${userConfig.directories.private}/".path = "~/.gitconfig-private";
      
      # Work projects
      includeIf."gitdir:~/${userConfig.directories.development}/${userConfig.directories.work}/".path = "~/.gitconfig-work";

      
      # ======================================================================
      # SAFE DIRECTORIES
      # ======================================================================
      # Mark directories as safe to prevent "dubious ownership" errors
      # Needed for directories owned by different users (like Homebrew)
      
      safe.directory = "/opt/homebrew";
    };
  };


  # --------------------------------------------------------------------------
  # ZSH CONFIGURATION
  # --------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    
    # Enable oh-my-zsh integration
    oh-my-zsh = {
      enable = true;
      
      # Oh-my-zsh theme
      # Popular themes: "robbyrussell", "agnoster", "powerlevel10k/powerlevel10k"
      theme = "robbyrussell";
      
      # Oh-my-zsh plugins
      # See: https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
      plugins = [
        # Version control
        "git"                  # Git aliases and functions
        "git-prompt"           # Git prompt customization
        "branch"               # Git branch utilities
        
        # Development tools
        "docker"               # Docker completion
        "docker-compose"       # Docker Compose completion
        "kubectl"              # Kubernetes completion
        "terraform"            # Terraform completion
        "gradle"               # Gradle completion
        "mvn"                  # Maven completion
        "ant"                  # Ant completion
        "sbt"                  # SBT completion
        "scala"                # Scala utilities
        "jenv"                 # Java environment manager
        "buf"                  # Buf (Protocol Buffers) completion
        "gh"                   # GitHub CLI completion
        "podman"               # Podman completion
        "localstack"           # LocalStack utilities
        
        # Cloud & Infrastructure
        "aws"                  # AWS CLI completion
        
        # Shell enhancements
        "fzf"                  # Fuzzy finder integration
        "z"                    # Jump to frequent directories
        "zsh-interactive-cd"   # Interactive cd with fzf
        "history"              # History utilities
        "common-aliases"       # Common shell aliases
        "aliases"              # Alias management
        "alias-finder"         # Find aliases for commands
        "autoenv"              # Auto-load environment variables
        
        # macOS specific
        "macos"                # macOS-specific aliases
        "iterm2"               # iTerm2 integration
        "brew"                 # Homebrew completion
        
        # UI & Display
        "colored-man-pages"    # Colorized man pages
        "colorize"             # Syntax highlighting for files
        "emoji"                # Emoji support
        "emoji-clock"          # Emoji clock in prompt
        "battery"              # Battery status in prompt
        
        # Productivity
        "fancy-ctrl-z"         # Ctrl-Z to toggle fg/bg
      ];

    };
    
    # Shell aliases
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      
      # Modern replacements
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      cat = "bat";
      
      # Git shortcuts
      g = "git";
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      
      # Kubernetes shortcuts
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";
      
      # Nix shortcuts
      nix-rebuild = "darwin-rebuild switch --flake ~/.config/nix-config";
      nix-update = "cd ~/.config/nix-config && nix flake update && darwin-rebuild switch --flake .";
    };
    
    # Additional zsh configuration
    initExtra = ''
      # Custom prompt or additional configuration
      
      # Enable case-insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      
      # Better history search
      bindkey '^R' history-incremental-search-backward
      
      # NVM configuration (if you install it manually)
      # export NVM_DIR="$HOME/.nvm"
      # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      
      # Coursier setup (if you install it)
      # export PATH="$PATH:$HOME/Library/Application Support/Coursier/bin"
      
      # Add any custom functions or configurations here
    '';
    
    # History configuration
    history = {
      size = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = true;  # Share history between sessions
    };
  };

  # --------------------------------------------------------------------------
  # VIM CONFIGURATION
  # --------------------------------------------------------------------------
  programs.vim = {
    enable = true;
    
    # Vim plugins
    plugins = with pkgs.vimPlugins; [
      # vim-sensible  # Sensible defaults
      # vim-airline   # Status bar
    ];
    
    # Vim configuration
    extraConfig = ''
      " Basic settings
      set number          " Show line numbers
      set relativenumber  " Relative line numbers
      set expandtab       " Use spaces instead of tabs
      set tabstop=2       " Tab width
      set shiftwidth=2    " Indent width
      set autoindent      " Auto-indent new lines
      syntax on           " Enable syntax highlighting
      
      " Search settings
      set ignorecase      " Case-insensitive search
      set smartcase       " Case-sensitive if uppercase present
      set hlsearch        " Highlight search results
      set incsearch       " Incremental search
    '';
  };

  # --------------------------------------------------------------------------
  # DIRENV - Automatic environment switching
  # --------------------------------------------------------------------------
  # Direnv automatically loads/unloads environment variables based on .envrc files
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # Better Nix integration
  };

  # ==========================================================================
  # DOTFILE MIGRATION STRATEGY
  # ==========================================================================
  # 
  # You mentioned you have existing dotfiles scattered in your home directory.
  # Here's how to migrate them:
  #
  # OPTION 1: Declarative (Recommended)
  # Copy the content from your existing dotfiles into the programs.* sections above.
  # For example, if you have custom aliases in ~/.zshrc, add them to shellAliases.
  #
  # OPTION 2: File-based
  # Use home.file to manage dotfiles as files:
  #
  # home.file.".zshrc".source = ./dotfiles/zshrc;
  # home.file.".gitconfig".source = ./dotfiles/gitconfig;
  #
  # OPTION 3: Hybrid
  # Use programs.* for well-supported programs (git, zsh, vim)
  # Use home.file for other dotfiles (.hammerspoon, .config/*, etc.)
  #
  # MIGRATION STEPS:
  # 1. Backup your existing dotfiles: cp ~/.zshrc ~/.zshrc.backup
  # 2. Copy content to this file or create files in home/dotfiles/
  # 3. Apply configuration: darwin-rebuild switch --flake ~/.config/nix-config
  # 4. Test everything works
  # 5. Remove backups once satisfied
  #
  # ==========================================================================

  # ==========================================================================
  # CONDITIONAL GIT CONFIGURATION FILES
  # ==========================================================================
  # These files are used by the conditional includes in programs.git.extraConfig
  # They allow you to have different git identities for work and personal projects
  
  home.file = {
    # ------------------------------------------------------------------------
    # PRIVATE/PERSONAL GIT CONFIGURATION
    # ------------------------------------------------------------------------
    # Used for projects in ~/${userConfig.directories.development}/${userConfig.directories.private}/
    # Email configured in user-config.nix
    
    ".gitconfig-private".text = ''
      [user]
          name = ${userConfig.user.name}
          email = ${userConfig.git.privateEmail}
          ${if userConfig.git.privateSigningKey != "" then "signingkey = ${userConfig.git.privateSigningKey}" else "# signingkey = YOUR_PERSONAL_GPG_KEY_ID"}
      
      ${if userConfig.git.privateSigningKey != "" then ''
      [commit]
          gpgsign = true
      '' else "# Uncomment to automatically sign commits with GPG:\n      # [commit]\n      #     gpgsign = true"}
    '';
    
    # ------------------------------------------------------------------------
    # WORK GIT CONFIGURATION
    # ------------------------------------------------------------------------
    # Used for projects in ~/${userConfig.directories.development}/${userConfig.directories.work}/
    # Email configured in user-config.nix
    
    ".gitconfig-work".text = ''
      [user]
          name = ${userConfig.user.name}
          email = ${userConfig.git.workEmail}
          ${if userConfig.git.workSigningKey != "" then "signingkey = ${userConfig.git.workSigningKey}" else "# signingkey = YOUR_WORK_GPG_KEY_ID"}
      
      ${if userConfig.git.workSigningKey != "" then ''
      [commit]
          gpgsign = true
      '' else "# Uncomment to automatically sign commits with GPG:\n      # [commit]\n      #     gpgsign = true"}
      
      # Optional: Add work-specific git settings here
      # For example, if your company uses a different default branch:
      # [init]
      #     defaultBranch = develop
    '';

    
    # ------------------------------------------------------------------------
    # OTHER DOTFILES (Examples)
    # ------------------------------------------------------------------------
    # Uncomment and customize as needed
    
    # Hammerspoon configuration
    # ".hammerspoon/init.lua".source = ./dotfiles/hammerspoon/init.lua;
    
    # iTerm2 configuration
    # Note: iTerm2 preferences are usually in ~/Library/Preferences/
    # You might need to export and manage them separately
    
    # SSH config
    # ".ssh/config".text = ''
    #   Host *
    #       AddKeysToAgent yes
    #       UseKeychain yes
    # '';
  };


  # ==========================================================================
  # SESSION VARIABLES
  # ==========================================================================
  # Environment variables for your user session
  
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    
    # Add custom paths
    # PATH = "$PATH:$HOME/bin";
  };

  # ==========================================================================
  # XDG BASE DIRECTORIES
  # ==========================================================================
  # Follow XDG Base Directory specification for cleaner home directory
  
  xdg.enable = true;
  
  # This creates:
  # ~/.config (XDG_CONFIG_HOME)
  # ~/.cache (XDG_CACHE_HOME)
  # ~/.local/share (XDG_DATA_HOME)
  # ~/.local/state (XDG_STATE_HOME)

  # ==========================================================================
  # HOME MANAGER ITSELF
  # ==========================================================================
  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
