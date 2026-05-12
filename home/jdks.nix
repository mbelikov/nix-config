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

{ config, pkgs, lib, ...}:

let
  jdk21 = pkgs.temurin-bin-21;
  jdk25 = pkgs.temurin-bin-25;

  jdk26 = pkgs.stdenv.mkDerivation rec {
    pname = "zulu-ca-jdk";
    version = "26.0.1";

    src = pkgs.fetchurl {
      url = "https://cdn.azul.com/zulu/bin/zulu26.30.11-ca-jdk${version}-macosx_aarch64.tar.gz";
      hash = "sha256-fxsSMjJTejCm7UqofWqE1Ca3Wr81Dr4jVnhKJh6dYHY=";  # ← we just need to know it
    };

    dontStrip = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out

      # Nix unpacks the tarball and cd's into the top-level dir.
      # Zulu macOS bundles have the JDK under Contents/Home/.
      cp -R Contents/Home/. $out/

      # Preserve license if present
      if [ -f $out/LICENSE ]; then
        install -D $out/LICENSE $out/share/zulu/LICENSE
        rm $out/LICENSE
      fi

      runHook postInstall
    '';

    preFixup = ''
      mkdir -p $out/nix-support
      printWords ${pkgs.setJavaClassPath} > $out/nix-support/propagated-build-inputs

      cat <<EOF >> $out/nix-support/setup-hook
      if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out; fi
      EOF
    '';

    meta = with lib; {
      description = "Azul Zulu Builds of OpenJDK - JDK ${version}";
      homepage = "https://www.azul.com/downloads/";
      platforms = [ "aarch64-darwin" ];
    };
  };
in
{
  # Put only the default JDK here:
  home.packages = [
    jdk26
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
      alias use-jdk26='use_jdk ${jdk26}'
    '';
}
