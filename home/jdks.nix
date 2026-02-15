# ============================================================================
# home/jdks.nix - Home Manager JDK Configuration
# ============================================================================
#
# This file manages user-level configuration of JDKs.
#
# IMPORTANT:
#   Only ONE full JDK can be symlinked into the Home Manager profile at a time,
#   otherwise their bin/ contents conflict (jwebserver, jar, jcmd, ...).
#
# ============================================================================

{ config, pkgs, ...}:

let
  jdk21 = pkgs.temurin-bin-21;
  jdk25 = pkgs.temurin-bin-25;
in
{
  # Put only the default JDK here:
  home.packages = [
    jdk21
  ];

  programs.zsh.initContent = ''
      use_jdk() {
        local jdk="$1"

        export JAVA_HOME="$jdk"
        export PATH="$JAVA_HOME/bin:$PATH"

        # zsh caches command paths; refresh after PATH change
        rehash

        java -version
      }

      alias use-jdk21='use_jdk ${jdk21}'
      alias use-jdk25='use_jdk ${jdk25}'
    '';
}
