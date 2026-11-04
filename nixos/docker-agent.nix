{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: let
  version = "1.150.0";
in
  stdenv.mkDerivation {
    pname = "docker-agent";
    inherit version;

    # Upstream ships a prebuilt static Go binary per platform. Update `version`
    # and re-run `nix store prefetch-file` on the new URL to bump.
    src = fetchurl {
      url = "https://github.com/docker/docker-agent/releases/download/v${version}/docker-agent-linux-arm64";
      hash = "sha256-Eq4JOERTGmDzLDRPSvuQvJKgEOqEOKWnYLPnn46ByOc=";
    };

    # No-op if the binary is fully static, but patches the interpreter if not.
    nativeBuildInputs = [autoPatchelfHook];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/docker-agent
      runHook postInstall
    '';

    meta = {
      description = "AI Agent Builder and Runtime by Docker Engineering";
      homepage = "https://github.com/docker/docker-agent";
      changelog = "https://github.com/docker/docker-agent/releases";
      license = lib.licenses.asl20;
      mainProgram = "docker-agent";
      platforms = ["aarch64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryArtifact];
    };
  }
