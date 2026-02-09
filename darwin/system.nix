# ============================================================================
# darwin/system.nix - macOS System Preferences
# ============================================================================
#
# This file contains macOS-specific settings like:
# - Dock configuration
# - Trackpad settings
# - Keyboard settings
# - Finder preferences
# - Screen saver
# - And much more!
#
# HOW TO FIND OPTIONS:
# - Online: https://daiderd.com/nix-darwin/manual/index.html
# - Search: https://github.com/LnL7/nix-darwin/blob/master/modules/system/defaults/
# - Command: darwin-option -l (after nix-darwin is installed)
#
# VALUE TYPES:
# - true/false: Boolean values (no quotes)
# - "string": Text values (in quotes)
# - 123: Numbers (no quotes)
# - null: Unset/default value
#
# ============================================================================

{ config, pkgs, ... }:

{
  # ==========================================================================
  # DOCK SETTINGS
  # ==========================================================================
  # Configure the macOS Dock appearance and behavior
  
  system.defaults.dock = {
    # Position the Dock on the left side of the screen
    # Options: "left", "bottom", "right"
    orientation = "left";
    
    # Dock icon size (in pixels)
    # Default is 64, you want 30% which is approximately 48 pixels
    # Range: 16-128
    tilesize = 32;
    
    # Magnification factor when hovering over icons
    # You want 1.5x magnification
    # This is enabled by setting largesize
    magnification = true;
    largesize = 50;
    
    # Automatically hide and show the Dock
    autohide = false;
    
    # Remove the auto-hiding Dock delay
    autohide-delay = 0.0;
    
    # Speed of the autohide animation
    autohide-time-modifier = 0.5;
    
    # Show indicator lights for open applications
    show-process-indicators = true;
    
    # Don't show recent applications in Dock
    show-recents = false;
    
    # Minimize windows using the "Scale" effect
    # Options: "genie", "scale", "suck"
    mineffect = "scale";
    
    # Make Dock icons of hidden applications translucent
    showhidden = true;
    
    # Don't automatically rearrange Spaces based on most recent use
    mru-spaces = false;
  };

  # ==========================================================================
  # TRACKPAD SETTINGS
  # ==========================================================================
  # Configure trackpad behavior
  
  system.defaults.trackpad = {
    # Enable tap to click
    Clicking = true;
    
    # Enable two-finger right-click
    TrackpadRightClick = true;
    
    # Enable three-finger drag
    # Note: This might require additional configuration in Accessibility settings
    TrackpadThreeFingerDrag = true;
    
    # Tracking speed (0.0 to 3.0, default is 1.0)
    # Higher = faster cursor movement
    # Adjust to your preference
    # scaling = 1.0;
  };

  # Additional trackpad settings via NSGlobalDomain
  system.defaults.NSGlobalDomain = {
    # Enable trackpad tap to click globally
    "com.apple.mouse.tapBehavior" = 1;
    
    # Trackpad: enable secondary click with two fingers
    "com.apple.trackpad.enableSecondaryClick" = true;
  };

  # ==========================================================================
  # KEYBOARD SETTINGS
  # ==========================================================================
  # Configure keyboard behavior and input sources
  
  system.defaults.NSGlobalDomain = {
    # Key repeat rate (lower = faster)
    # Range: 2 (fast) to 120 (slow)
    # Default is 6, you want "fast" so let's use 2
    KeyRepeat = 2;
    
    # Delay until repeat (in milliseconds)
    # You want 0.2s = 200ms
    # Range: 15 (225ms) to 120 (1800ms)
    # The value is in units of 15ms, so 15 = 225ms
    # For 200ms, we use the closest value: 15 (which gives 225ms)
    InitialKeyRepeat = 15;
    
    # Disable press-and-hold for keys in favor of key repeat
    ApplePressAndHoldEnabled = false;
  };

  # Keyboard input sources configuration
  # Note: Input sources (ABC, German, Russian) need to be configured
  # via system preferences or using a custom script, as nix-darwin
  # doesn't have direct options for this yet.
  # See SETUP-GUIDE.md for manual configuration steps.

  # Function keys behavior
  # Make F1, F2, etc. behave as standard function keys
  # (requires pressing Fn to access special features)
  system.keyboard = {
    enableKeyMapping = true;
    # Note: fnState option might not be available in all nix-darwin versions
    # You may need to configure this manually in System Preferences
  };

  # ==========================================================================
  # FINDER SETTINGS
  # ==========================================================================
  # Configure Finder appearance and behavior
  
  system.defaults.finder = {
    # Put folders first sorting by name
    _FXSortFoldersFirst = true;

    # Show all filename extensions
    AppleShowAllExtensions = true;
    
    # Show status bar at bottom of Finder windows
    ShowStatusBar = true;
    
    # Show path bar at bottom of Finder windows
    ShowPathbar = true;
    
    # Default view style for folders
    # Options: "icnv" (icon), "Nlsv" (list), "clmv" (column), "glyv" (gallery)
    FXPreferredViewStyle = "Nlsv";
    
    # Search scope when performing a search
    # Options: "SCcf" (current folder), "SCev" (entire volume), "SCsp" (previous scope)
    FXDefaultSearchScope = "SCcf";
    
    # Disable warning when changing a file extension
    FXEnableExtensionChangeWarning = false;
    
    # Show hidden files
    AppleShowAllFiles = true;
    
    # Show the ~/Library folder
    # Note: This is handled separately via chflags command
  };

  # ==========================================================================
  # SCREEN SAVER SETTINGS
  # ==========================================================================
  # Configure screen saver
  
  system.defaults.screensaver = {
    # Ask for password after screen saver begins
    askForPassword = true;
    
    # Delay before password is required (in seconds)
    # 0 = immediately
    askForPasswordDelay = 5;
  };
  
  # Note: Setting specific screen saver (like "Kelp Dark") requires
  # manual configuration or custom scripts, as nix-darwin doesn't
  # provide direct options for screen saver selection.
  # See SETUP-GUIDE.md for instructions.

  # ==========================================================================
  # MENU BAR SETTINGS
  # ==========================================================================
  # Configure menu bar appearance
  
  system.defaults.NSGlobalDomain = {
    # Always show menu bar (don't auto-hide)
    _HIHideMenuBar = false;
  };

  # ==========================================================================
  # WINDOW MANAGEMENT
  # ==========================================================================
  # Configure window behavior
  
  system.defaults.NSGlobalDomain = {
    # Expand save panel by default
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    
    # Expand print panel by default
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;
    
    # Save to disk (not to iCloud) by default
    NSDocumentSaveNewDocumentsToCloud = false;
  };

  # ==========================================================================
  # SCREENSHOTS
  # ==========================================================================
  # Configure screenshot behavior
  
  system.defaults.screencapture = {
    # Save screenshots to ~/Pictures/Screenshots
    location = "~/Pictures/Screenshots";
    
    # Screenshot format
    # Options: "png", "jpg", "pdf", "tiff", "bmp", "gif"
    type = "png";
    
    # Disable shadow in screenshots
    disable-shadow = false;
  };

  # ==========================================================================
  # ACTIVITY MONITOR
  # ==========================================================================
  # Configure Activity Monitor preferences
  
  system.defaults.ActivityMonitor = {
    # Show all processes
    ShowCategory = 100;
    
    # Sort by CPU usage
    SortColumn = "CPUUsage";
    SortDirection = 0;
  };

  # ==========================================================================
  # MISC SETTINGS
  # ==========================================================================
  
  system.defaults.NSGlobalDomain = {
    # Disable automatic capitalization
    NSAutomaticCapitalizationEnabled = false;
    
    # Disable smart dashes
    NSAutomaticDashSubstitutionEnabled = false;
    
    # Disable automatic period substitution
    NSAutomaticPeriodSubstitutionEnabled = false;
    
    # Disable smart quotes
    NSAutomaticQuoteSubstitutionEnabled = false;
    
    # Disable auto-correct
    NSAutomaticSpellingCorrectionEnabled = false;
  };
}
