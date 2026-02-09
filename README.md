# nix-config

macOS system configuration using nix-darwin and home-manager.

Inspired by [gvolpe/nix-config](https://github.com/gvolpe/nix-config).

---

## 📋 Prerequisites

- macOS 15.0+ (it could work on older versions, though)
- Administrator access
- ~10GB free disk space

## 🚀 Quick Setup

### 1. Install Nix

```bash
curl -L https://nixos.org/nix/install | sh
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
- `system.hostname` - Computer name (run `scutil --get LocalHostName`)
- `system.architecture` - `aarch64-darwin` (Apple Silicon) or `x86_64-darwin` (Intel)

**Optional:**
- `directories.development` - Change from "Development" to "dev", "Code", etc.
- `git.privateSigningKey` / `git.workSigningKey` - GPG key IDs for commit signing

### 5. Apply Configuration

```bash
# First-time installation (installs nix-darwin)
sudo -H env USER_CONFIG_NIX=/Users/<your-home-directory>/.config/nix/user-config.nix nix \
  --extra-experimental-features "nix-command flakes" \
  run nix-darwin -- switch --flake ./nix-config --impure

# Subsequent updates
sudo -H env USER_CONFIG_NIX=/Users/<your-home-directory>/.config/nix/user-config.nix \
  darwin-rebuild switch --flake ~/.config/nix-config --impure
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
- Lens, LM Studio
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
nix-rebuild
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
3. Apply: `nix-rebuild`

**Homebrew casks** (GUI apps):
1. Add to `darwin/configuration.nix` → `homebrew.casks`
2. Apply: `nix-rebuild`

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

## 📚 Resources

- [nix-darwin Configuration Options](https://nix-darwin.github.io/nix-darwin/manual/index.html)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Package Search](https://search.nixos.org/packages)
- [Nix reference manual](https://nix.dev/reference/nix-manual)
- [Nix language basics](https://nix.dev/tutorials/nix-language)

---

## 🤝 Contributing

This is a personal configuration, but feel free to:
- Use it as inspiration for your own config
- Suggest improvements via issues/PRs
- Ask questions about specific configurations

This configuration is provided as-is for personal use and learning.
