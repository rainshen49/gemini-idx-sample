{ pkgs, projectId, ... }:
let
  flutter_sdk = pkgs.fetchurl {
    url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.3-stable.tar.xz";
    sha256 = "sha256-nF9wuhGLkWNVIUSQGi79kdQLIqaKBOZycdalrZNug2g=";
    name = "flutter_linux_3.22.3-stable.tar.xz";
  };
in
{
  packages = [
    pkgs.gnutar
    pkgs.xz
  ];
  bootstrap = ''
    mkdir -p "$out"
    cp -rf ${./app}/. "$out"
    chmod -R +w "$out"
    # Apply project ID to configs
    sed -e 's/<project-id>/${projectId}/' ${./app/.idx/dev.nix} > "$out/.idx/dev.nix"
    # Install the flutter SDK
    tar -xf ${flutter_sdk} -C "$out/.idx"
  '';
}
