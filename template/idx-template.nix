{ pkgs, projectId, ... }:
{
  bootstrap = ''
    mkdir -p "$out"
    cp -rf ${./app}/. "$out"
    chmod -R +w "$out"

    # Apply project ID to configs
    sed -e 's/<project-id>/${projectId}/' ${./app/.idx/dev.nix} > "$out/.idx/dev.nix"
  '';
}
