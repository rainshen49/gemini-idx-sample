{ pkgs, projectId, ... }: {
  packages = [
    pkgs.curl
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
    curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.3-stable.tar.xz
    tar -xf "./flutter_linux_3.22.3-stable.tar.xz" -C "$out/.idx"
    rm ./flutter_linux_3.22.3-stable.tar.xz
  '';
}
