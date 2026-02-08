# nix-config

macOS system configuration using nix-darwin and home-manager.

Inspired by [gvolpe/nix-config](https://github.com/gvolpe/nix-config).

---

## 📋 Prerequisites

- macOS 12.0+ (Monterey or later)
- Administrator access
- ~5GB free disk space

## 🚀 Quick Setup

### 1. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Close and reopen your terminal after installation.

### 2. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow post-installation instructions to add Homebrew to your PATH.

### 3. Clone This Repository

```bash
mkdir -p ~/.config
cd ~/.config
git clone <your-repo-url> nix-config
cd nix-config
```

### 4. Customize Your Configuration

**Edit `user-config.nix`** - This is the ONLY file you need to customize:

```bash
vim user-config.nix
```

**Required changes:**
- `user.name` - Your full name
- `user.username` - Your macOS username (run `whoami`)
- `user.email` - Your default email
- `git.privateEmail` - Personal email for `~/development/private/` projects
- `git.workEmail` - Work email for `~/development/work/` projects
- `system.hostname` - Computer name (run `scutil --get ComputerName`)
- `system.architecture` - `aarch64-darwin` (Apple Silicon) or `x86_64-darwin` (Intel)

**Optional:**
- `directories.development` - Change from "Development" to "dev", "Code", etc.
- `git.privateSigningKey` / `git.workSigningKey` - GPG key IDs for commit signing

### 5. Apply Configuration

```bash
# First-time installation (installs nix-darwin)
nix run nix-darwin -- switch --flake .

# Subsequent updates
darwin-rebuild switch --flake ~/.config/nix-config
```

**This will take 10-30 minutes** on first run.

### 6. Restart Your System

```bash
sudo shutdown -r now
```

### 7. Create Project Directories

```bash
mkdir -p ~/development/private  # Personal projects
mkdir -p ~/development/work     # Work projects
```

---

## ✅ Verify Setup

### Check System Settings
- Dock should be on the left with smaller size and magnification
- Trackpad tap-to-click should work
- Key repeat should be fast

### Check Git Identities

```bash
# Personal projects
cd ~/development/private
git config user.email  # Should show your personal email

# Work projects  
cd ~/development/work
git config user.email  # Should show your work email
```

---

## 📦 What Gets Configured

### System Settings (darwin/system.nix)
- **Dock**: Left position, 30% size, 1.5x magnification
- **Trackpad**: Tap to click, two-finger right-click, three-finger drag
- **Keyboard**: Fast key repeat, 0.2s delay
- **Finder**: Show extensions, status bar, path bar
- **Screenshots**: Saved to ~/Pictures/Screenshots

### Development Tools (home/default.nix)
**Via Nix:**
- kubectl, helm, k9s, terraform, kind
- ripgrep, fd, bat, eza
- gh (GitHub CLI), git-lfs

**Via Homebrew:**
- Docker Desktop, VSCode, iTerm2
- Hammerspoon, MonitorControl
- Lens, Parallels, LM Studio
- iStat Menus
- maven, ant, fzf, mactop, mole

### Shell Configuration
- zsh with oh-my-zsh
- Modern CLI tools (eza, bat, ripgrep)
- Git, Docker, kubectl completions
- Useful aliases and shortcuts

### Git Configuration
- **Automatic identity switching** based on project directory
- **Git LFS** enabled
- **Line ending handling** (CRLF → LF on commit)
- **Safe directory** for Homebrew

---

## 🔧 Daily Usage

### Update Configuration

After editing any `.nix` files:

```bash
darwin-rebuild switch --flake ~/.config/nix-config
```

### Update Packages

```bash
cd ~/.config/nix-config
nix flake update
darwin-rebuild switch --flake .
```

### Rollback Changes

If something breaks:

```bash
# List previous generations
darwin-rebuild --list-generations

# Rollback to previous generation
darwin-rebuild --rollback
```

### Add Packages

**Nix packages** (CLI tools):
1. Search: `nix search nixpkgs <package-name>`
2. Add to `home/default.nix` → `home.packages`
3. Apply: `darwin-rebuild switch --flake ~/.config/nix-config`

**Homebrew casks** (GUI apps):
1. Add to `darwin/configuration.nix` → `homebrew.casks`
2. Apply: `darwin-rebuild switch --flake ~/.config/nix-config`

---

## 🗑️ Uninstall / Undo

### Remove nix-darwin Configuration

```bash
# Uninstall nix-darwin
/nix/var/nix/profiles/system/sw/bin/darwin-rebuild uninstall

# Remove configuration files
rm -rf ~/.config/nix-config

# Remove generated files
rm -f ~/.gitconfig-private ~/.gitconfig-work
```

### Uninstall Nix Completely

```bash
# Remove Nix
/nix/nix-installer uninstall
```

### Restore macOS Defaults

System settings will remain as configured. To reset:
- Go to System Preferences and manually adjust settings
- Or use `defaults delete` commands for specific preferences

### Uninstall Homebrew (Optional)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

---

## 📁 Project Structure

```
nix-config/
├── user-config.nix          # ⭐ Create/edit this file for personal settings
├── user-config.nix.example  # Template for sharing
├── flake.nix                # Main entry point
├── flake.lock               # Lock file (auto-generated)
├── darwin/
│   ├── configuration.nix    # System packages, Homebrew, services
│   └── system.nix           # macOS preferences (Dock, trackpad, etc.)
└── home/
    └── default.nix          # User packages, dotfiles, shell config
```

---

## 🎯 Key Features

✅ **Centralized Configuration** - Edit `user-config.nix` once, updates everywhere  
✅ **Reproducible** - Same config = same result every time  
✅ **Rollback Support** - Easy to revert if something breaks  
✅ **Git Identity Switching** - Automatic email switching by directory  
✅ **Heavily Commented** - Every option explained  
✅ **Hybrid Approach** - Nix + Homebrew for best macOS experience  

---

## 🐛 Troubleshooting

### "error: experimental Nix feature 'flakes' is disabled"

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Homebrew casks not installing

Install Homebrew first, then rebuild:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
darwin-rebuild switch --flake ~/.config/nix-config
```

### Settings not applying

1. Check syntax: `nix flake check ~/.config/nix-config`
2. Some settings require logout/restart
3. Use verbose output: `darwin-rebuild switch --flake ~/.config/nix-config --show-trace`

### Git identity not changing

1. Verify directory structure matches `user-config.nix`
2. Check which config is active: `git config --show-origin user.email`
3. Ensure you're in the correct subdirectory (`~/Development/private/` or `~/Development/work/`)

---

## 📝 Manual Configuration Steps

Some settings can't be automated:

1. **Keyboard Input Sources**: System Preferences → Keyboard → Input Sources → Add ABC, German, Russian
2. **Function Keys**: System Preferences → Keyboard → Check "Use F1, F2, etc. keys as standard function keys"
3. **Screen Saver**: System Preferences → Screen Saver → Select "Kelp Dark"
4. **Three-Finger Drag**: System Preferences → Accessibility → Pointer Control → Trackpad Options → Enable dragging → three finger drag

---

## 📚 Resources

- [Nix Darwin Manual](https://daiderd.com/nix-darwin/manual/index.html)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Package Search](https://search.nixos.org/packages)
- [Nix Language Basics](https://nixos.org/manual/nix/stable/language/)

---

## 🤝 Contributing

This is a personal configuration, but feel free to:
- Use it as inspiration for your own config
- Suggest improvements via issues/PRs
- Ask questions about specific configurations

This configuration is provided as-is for personal use and learning.
