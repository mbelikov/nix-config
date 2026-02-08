# ============================================================================
# flake.nix - Main Entry Point for Nix Configuration
# ============================================================================
#
# This file is the heart of your Nix configuration. It uses "flakes", which is
# the modern way to manage Nix projects with better reproducibility.
#
# KEY CONCEPTS:
# - Flakes provide a standardized way to write Nix expressions
# - They lock dependencies for reproducibility (see flake.lock)
# - They have inputs (dependencies) and outputs (what this flake produces)
#
# STRUCTURE:
# - description: Human-readable description of this flake
# - inputs: External dependencies (nixpkgs, nix-darwin, home-manager)
# - outputs: What this flake produces (your system configuration)
#
# ============================================================================

{
  description = "macOS system configuration using nix-darwin and home-manager";

  # ==========================================================================
  # INPUTS - External Dependencies
  # ==========================================================================
  # These are the building blocks we use to construct our configuration.
  # Think of them as "imports" or "dependencies" in other languages.
  
  inputs = {
    # nixpkgs: The main repository of Nix packages (70,000+ packages!)
    # We use the unstable branch for latest packages, but you can use
    # "nixpkgs-24.05-darwin" for more stability
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin: Manages macOS system configuration
    # This is what allows us to configure Dock, keyboard, trackpad, etc.
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";  # Use our nixpkgs version
    };

    # home-manager: Manages user-level configuration (dotfiles, user packages)
    # This handles things like .zshrc, .gitconfig, and user-specific tools
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";  # Use our nixpkgs version
    };
  };

  # ==========================================================================
  # OUTPUTS - What This Flake Produces
  # ==========================================================================
  # The outputs function takes our inputs and produces system configurations.
  # 
  # PARAMETERS:
  # - self: Reference to this flake itself
  # - nixpkgs: The Nix packages repository
  # - nix-darwin: The macOS configuration framework
  # - home-manager: The user configuration framework
  
  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }@inputs:
  
  let
    # ========================================================================
    # CENTRALIZED USER CONFIGURATION
    # ========================================================================
    # Import user-specific settings from user-config.nix
    # This is the ONLY file you need to edit for personal settings!

    # Prefer a local-only config outside the repo
    userConfigNix = builtins.getEnv "USER_CONFIG_NIX";

    userConfig =
      if builtins.pathExists userConfigNix then
        import (builtins.path { path = userConfigNix; name = "local-user-config"; })
      else if builtins.pathExists ./user-config.nix then
        import ./user-config.nix
      else
        throw ''
          Missing user config.

          Create:
            ~/.config/nix/user-config.nix

          Or add ./user-config.nix (tracked by git) if you want it in-repo.
        '';

  in
  {

    
    # ========================================================================
    # DARWIN CONFIGURATIONS
    # ========================================================================
    # This section defines macOS system configurations.
    # The hostname and architecture are now read from user-config.nix
    #
    # You can add more configurations for different machines by editing
    # user-config.nix and adding additional entries here.
    
    darwinConfigurations.${userConfig.system.hostname} = nix-darwin.lib.darwinSystem {
      # System architecture from user-config.nix
      system = userConfig.system.architecture;
      
      # Special arguments passed to all modules
      # This makes these values available in all our configuration files
      specialArgs = { 
        inherit inputs userConfig;  # Pass inputs and userConfig to all modules
      };

      
      # ======================================================================
      # MODULES - Configuration Building Blocks
      # ======================================================================
      # Modules are separate .nix files that contain parts of our config.
      # This keeps things organized and manageable.
      #
      # ORDER MATTERS: Later modules can override earlier ones
      
      modules = [
        # Main darwin configuration (system packages, services, etc.)
        ./darwin/configuration.nix
        
        # macOS system settings (Dock, trackpad, keyboard, etc.)
        ./darwin/system.nix
        
        # ===================================================================
        # HOME-MANAGER INTEGRATION
        # ===================================================================
        # This integrates home-manager as a nix-darwin module, allowing
        # user-level configuration to be managed alongside system config.
        
        home-manager.darwinModules.home-manager
        {
          # Use system-level nixpkgs for home-manager (ensures consistency)
          home-manager.useGlobalPkgs = true;
          
          # Install packages to /etc/profiles instead of ~/.nix-profile
          # This is recommended for nix-darwin integration
          home-manager.useUserPackages = true;
          
          # Username from user-config.nix
          home-manager.users.${userConfig.user.username} = import ./home/default.nix;
          
          # Pass extra arguments to home-manager modules
          home-manager.extraSpecialArgs = { inherit inputs userConfig; };

        }
      ];
    };
  };
}
