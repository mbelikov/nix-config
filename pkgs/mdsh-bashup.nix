# ============================================================================
# pkgs/mdsh-bashup.nix - bashup/mdsh (literate programming in bash)
# ============================================================================
#
# WHY IS THIS A LOCAL PACKAGE?
# There is no Homebrew formula for bashup/mdsh, and nixpkgs does not package
# it either. So we build it ourselves from a pinned git revision.
#
# WHY THE "-bashup" SUFFIX?
# nixpkgs ALREADY has an unrelated `pkgs.mdsh` (zimbatm's Rust "Markdown
# shell pre-processor"). Naming this attribute plain `mdsh` in the overlay
# would silently shadow that package system-wide. The suffix keeps both
# usable; the installed binary is still called `mdsh`.
#
# WHY buildInputs = [ bash ]?
# bin/mdsh ships a `#!/usr/bin/env bash` shebang but needs bash 4+ features
# (associative arrays et al). Apple froze /bin/bash at 3.2 to avoid GPLv3,
# so that interpreter cannot run mdsh.
#
# Listing bash in buildInputs puts it on HOST_PATH, which is where
# fixupPhase's patchShebangs looks. patchShebangs then rewrites the shebang
# line of OUR COPY of bin/mdsh under $out, pinning an exact store path.
#
# TO BE CLEAR: nothing outside this package is modified. patchShebangs only
# walks files in $out, inside the build sandbox. /bin/bash is untouched
# (it also lives on macOS's sealed, read-only system volume, so it could
# not be written to in any case). A shebang is a per-file declaration the
# kernel reads at exec() time, so this affects the `mdsh` process only --
# your shell and every other script are unaffected.
#
# Pinning also buys reproducibility: `/usr/bin/env bash` would resolve via
# $PATH at RUNTIME, so unpatched, mdsh's behaviour would vary with whatever
# bash happened to be first on PATH (macOS 3.2, Homebrew, Nix, ...).
#
# HOW TO UPDATE:
# 1. Pick a new commit from https://github.com/bashup/mdsh/commits/master
# 2. Set `rev` to it and `version` to "0-unstable-YYYY-MM-DD" (commit date)
# 3. Get the hash:
#      nix-prefetch-url --unpack https://github.com/bashup/mdsh/archive/<rev>.tar.gz
#      nix hash convert --hash-algo sha256 --to sri <output-of-above>
#
# ============================================================================

{ lib, stdenvNoCC, fetchFromGitHub, bash }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mdsh-bashup";
  version = "0-unstable-2022-07-01";

  src = fetchFromGitHub {
    owner = "bashup";
    repo = "mdsh";
    rev = "31cfd34fa34d01f1b34bc561ec59148910555022";
    hash = "sha256-Q4sILeZkRWTRToxEL7YUoRcMBsJYyjqGLtKQke7ITCk=";
  };

  # Puts bash on HOST_PATH so patchShebangs can repoint the shebang of the
  # mdsh copy in $out at a store bash. Does not touch /bin/bash -- see the
  # "WHY buildInputs = [ bash ]?" note above.
  buildInputs = [ bash ];

  # Plain shell script: nothing to configure, nothing to compile.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/mdsh $out/bin/mdsh
    runHook postInstall
  '';

  # Cheap smoke test: proves the patched shebang actually resolves to a
  # working bash, which is the whole point of the buildInputs above.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/mdsh --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Multi-lingual, Markdown-based literate programming in run-anywhere bash";
    homepage = "https://github.com/bashup/mdsh";
    license = lib.licenses.mit;
    mainProgram = "mdsh";
    platforms = lib.platforms.unix;
  };
})
