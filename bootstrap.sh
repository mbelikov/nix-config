#!/usr/bin/env bash
# ============================================================================
# bootstrap.sh - Full machine bootstrap before first nix-darwin activation
# ============================================================================
#
# Run this script ONCE on any fresh macOS machine (or VM).
# It is idempotent — safe to run multiple times.
#
# What it does (in order):
#   1. Installs Nix (multi-user) if not already installed
#   2. Installs Homebrew if not already installed
#   3. Renames /etc/bashrc and /etc/zshrc so nix-darwin can manage them
#   4. Prints the nix-darwin activation command to run next
#
# Usage:
#   chmod +x bootstrap.sh
#   ./bootstrap.sh
#
# ============================================================================

set -euo pipefail

CURRENT_USER="$(whoami)"
USER_HOME="/Users/${CURRENT_USER}"
NIX_CONFIG_DIR="${USER_HOME}/.config/nix-config"

echo ""
echo "============================================================"
echo "  macOS bootstrap — user: ${CURRENT_USER}"
echo "============================================================"
echo ""

# ============================================================================
# STEP 1 — Install Nix
# ============================================================================
echo "==> [1/3] Checking Nix installation..."

if command -v nix &>/dev/null; then
  echo "    [ok]   Nix is already installed ($(nix --version 2>/dev/null || echo 'version unknown'))"
else
  echo "    [install] Installing Nix..."
  curl -L https://nixos.org/nix/install | sh
  echo "    [done] Nix installed."
  echo ""
  echo "    NOTE: Nix added shell hooks. Source your shell or open a new"
  echo "    terminal before running the nix-darwin activation command below."
fi

echo ""

# ============================================================================
# STEP 2 — Install Homebrew
# ============================================================================
echo "==> [2/3] Checking Homebrew installation..."

if command -v brew &>/dev/null; then
  echo "    [ok]   Homebrew is already installed ($(brew --version | head -1))"
else
  echo "    [install] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "    [done] Homebrew installed."
fi

echo ""

# ============================================================================
# STEP 3 — Rename /etc files so nix-darwin can manage them
# ============================================================================
echo "==> [3/3] Checking /etc files that nix-darwin needs to manage..."

for file in /etc/bashrc /etc/zshrc; do
  if [ -f "$file" ]; then
    backup="${file}.before-nix-darwin"
    if [ -f "$backup" ]; then
      echo "    [skip] ${backup} already exists, skipping ${file}"
    else
      echo "    [mv]   ${file} -> ${backup}"
      sudo mv "$file" "$backup"
    fi
  else
    echo "    [ok]   ${file} does not exist, nothing to do"
  fi
done

echo ""

# ============================================================================
# DONE — Print next steps
# ============================================================================
echo "============================================================"
echo "  Bootstrap complete!"
echo "============================================================"
echo ""
echo "Next steps:"
echo ""
echo "  1. Clone this config repo (if not done yet):"
echo "       git clone <your-repo-url> ${NIX_CONFIG_DIR}"
echo ""
echo "  2. Create your user config (if not done yet):"
echo "       cp ${NIX_CONFIG_DIR}/user-config.nix.example \\"
echo "          ${USER_HOME}/.config/nix/user-config.nix"
echo "       # then edit it with your personal settings"
echo ""
echo "  3. Run nix-darwin for the first time:"
echo ""
echo "       sudo -H env \\"
echo "         USER_CONFIG_NIX=${USER_HOME}/.config/nix/user-config.nix \\"
echo "         nix \\"
echo "           --extra-experimental-features \"nix-command flakes\" \\"
echo "           run nix-darwin -- switch \\"
echo "           --flake ${NIX_CONFIG_DIR} \\"
echo "           --impure"
echo ""
echo "  After the first activation, use darwin-rebuild for subsequent updates:"
echo ""
echo "       sudo -H env \\"
echo "         USER_CONFIG_NIX=${USER_HOME}/.config/nix/user-config.nix \\"
echo "         darwin-rebuild switch \\"
echo "           --flake ${NIX_CONFIG_DIR} \\"
echo "           --impure"
echo ""
