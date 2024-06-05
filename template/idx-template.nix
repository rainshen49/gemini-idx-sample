{pkgs, projectId, ...}: {
  bootstrap = ''
    mkdir -p "$out"
    cp -rf ${./app} "$out"
    mkdir -p "$out"/.idx
    chmod -R +w "$out"
    sed 's/<project-id>/${projectId}/' ${./dev.nix} > "$out/.idx/dev.nix"
  '';
}