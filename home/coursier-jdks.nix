# ============================================================================
# home/coursier-jdks.nix - Coursier post install Configuration
# ============================================================================
#
# ============================================================================

{ pkgs, lib, ... }:

{
  home.sessionPath = [
    "$HOME/Library/Application Support/Coursier/bin"
  ];

  home.activation.coursierJdks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail

    CS="${pkgs.coursier}/bin/cs"

    get_jvm() {
      local jvm="$1"

      echo "[home manager] Installing via Coursier: $jvm"
      echo "$CS java --jvm $jvm"
      "$CS" java --jvm "$jvm" --env >/dev/null
    }

    get_jvm "temurin:21"
    get_jvm "temurin:25"
  '';
}