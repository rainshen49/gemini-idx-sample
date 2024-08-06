{ pkgs, projectId, ... }:
let
  flutter_sdk = pkgs.fetchzip {
    url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.3-stable.tar.xz";
    sha256 = "sha256-rLglM2KIsgrjddNgdFbJiOCgKQQQFFUuPMP6bpZCEx8=";
  };
in
{
  packages = [];
  bootstrap = ''
    mkdir -p "$out"
    cp -rf ${./app}/. "$out"
    chmod -R +w "$out"

    # Apply project ID to configs
    sed -e 's/<project-id>/${projectId}/' ${./app/.idx/dev.nix} > "$out/.idx/dev.nix"

    # Install the flutter SDK
    mkdir "$out/.flutter"
    cp -rf ${flutter_sdk}/. "$out/.flutter"
    chmod -R +w "$out/.flutter"
  '';
}
