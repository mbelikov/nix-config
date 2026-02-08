# ============================================================================
# darwin/configuration.nix - Main Darwin System Configuration
# ============================================================================
#
# This file contains the core nix-darwin configuration including:
# - Nix settings and features
# - System-wide packages
# - Homebrew integration
# - System services
#
# SYNTAX NOTE: This is a Nix function that takes { config, pkgs, ... } as input
# and returns an attribute set { ... } with configuration options.
#
# ============================================================================

{ config, pkgs, userConfig, ... }:

{

  # ==========================================================================
  # NIX SETTINGS
  # ==========================================================================
  # Configure the Nix package manager itself
  
  nix.settings = {
    # Enable experimental features (required for flakes)
    experimental-features = "nix-command flakes";
    
    # Optimize storage by hard-linking identical files
    auto-optimise-store = true;
  };

  # ==========================================================================
  # NIX-DARWIN SETTINGS
  # ==========================================================================
  
  # Enable Touch ID for sudo authentication
  # This allows you to use your fingerprint instead of typing password for sudo
  security.pam.enableSudoTouchIdAuth = true;

  # ==========================================================================
  # SYSTEM PACKAGES
  # ==========================================================================
  # Packages installed system-wide (available to all users)
  #
  # HOW TO FIND PACKAGES:
  # - Search online: https://search.nixos.org/packages
  # - Command line: nix search nixpkgs <package-name>
  # - Example: nix search nixpkgs htop
  #
  # NOTE: User-specific packages should go in home/default.nix instead
  
  environment.systemPackages = with pkgs; [
    # Essential tools
    vim           # Text editor (always good to have)
    git           # Version control
    curl          # HTTP client
    wget          # File downloader
    
    # System monitoring
    htop          # Interactive process viewer
    
    # Development tools (basic set - more in modules/development.nix)
    jq            # JSON processor
  ];

  # ==========================================================================
  # HOMEBREW INTEGRATION
  # ==========================================================================
  # nix-darwin can manage Homebrew declaratively!
  #
  # WHY USE HOMEBREW WITH NIX?
  # - Some macOS apps aren't available in nixpkgs
  # - Some apps work better when installed via Homebrew
  # - GUI applications (casks) are often easier via Homebrew
  #
  # IMPORTANT: You need to install Homebrew first:
  # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  homebrew = {
    enable = true;
    
    # Update Homebrew and packages during nix-darwin activation
    onActivation = {
      autoUpdate = true;      # Update Homebrew itself
      upgrade = true;         # Upgrade all packages
      cleanup = "zap";        # Remove unlisted packages and old versions
    };

    # ========================================================================
    # HOMEBREW TAPS
    # ========================================================================
    # Taps are third-party repositories for Homebrew
    # Add taps here if you need packages from non-standard sources
    
    taps = [
      # Example: "homebrew/cask-fonts"
    ];

    # ========================================================================
    # HOMEBREW PACKAGES (CLI tools)
    # ========================================================================
    # Command-line tools installed via Homebrew
    # Use this for tools not available or problematic in nixpkgs
    
    brews = [
      # Development tools
      "maven"       # Java build tool
      "ant"         # Java build tool
      
      # Shell tools
      "fzf"         # Fuzzy finder
      
      # System utilities
      "mactop"      # macOS activity monitor
      
      # Network tools
      "mole"        # SSH tunnel manager
    ];

    # ========================================================================
    # HOMEBREW CASKS (GUI Applications)
    # ========================================================================
    # GUI applications installed via Homebrew Cask
    # This is often the best way to install macOS applications
    
    casks = [
      # Development
      "docker"              # Docker Desktop
      "visual-studio-code"  # VSCode
      "iterm2"              # Terminal emulator
      
      # Utilities
      "hammerspoon"         # Automation tool
      "monitorcontrol"      # Monitor brightness control
      
      # Kubernetes tools
      "lens"                # Kubernetes IDE
      
      # Virtualization
      "parallels"           # Parallels Desktop
      
      # AI/ML
      "lm-studio"           # Local LLM runner
      
      # System monitoring
      "istat-menus"         # System monitor
    ];

    # ========================================================================
    # MAC APP STORE APPLICATIONS
    # ========================================================================
    # Install apps from Mac App Store using mas (Mac App Store CLI)
    # 
    # HOW TO FIND APP IDs:
    # 1. Install mas: brew install mas
    # 2. Search: mas search "App Name"
    # 3. Or find in URL: https://apps.apple.com/app/id<NUMBER>
    
    masApps = {
      # Example: "Xcode" = 497799835;
    };
  };

  # ==========================================================================
  # SYSTEM DEFAULTS
  # ==========================================================================
  # Basic system settings (more detailed settings in darwin/system.nix)
  
  system = {
    # macOS system version - this should match your target macOS version
    # Check with: sw_vers
    stateVersion = 5;
    
    defaults = {
      # Disable "Are you sure you want to open this application?" dialog
      LaunchServices.LSQuarantine = false;
    };
  };

  # ==========================================================================
  # PROGRAMS
  # ==========================================================================
  # Enable and configure system programs
  
  programs = {
    # zsh is the default shell on macOS
    zsh.enable = true;
  };

  # ==========================================================================
  # SERVICES
  # ==========================================================================
  # System services configuration
  
  services = {
    # Nix daemon - required for multi-user Nix installation
    nix-daemon.enable = true;
  };

  # ==========================================================================
  # FONTS
  # ==========================================================================
  # Install fonts system-wide
  #
  # HOW TO FIND FONTS:
  # - Search: https://search.nixos.org/packages?query=font
  # - Many fonts are in pkgs like: pkgs.fira-code, pkgs.jetbrains-mono
  
  fonts.packages = with pkgs; [
    # Example fonts (uncomment to enable)
    # fira-code
    # jetbrains-mono
    # (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];

  # ==========================================================================
  # USERS
  # ==========================================================================
  # User account configuration from user-config.nix
  
  users.users.${userConfig.user.username} = {
    name = userConfig.user.username;
    home = "/Users/${userConfig.user.username}";
  };

}
