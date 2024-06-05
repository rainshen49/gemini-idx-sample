{pkgs, projectId, ...}: {
  bootstrap = ''
    mkdir -p "$out"
    cp -rf ${./app}/. "$out"
    chmod -R +w "$out"
    sed 's/<project-id>/${projectId}/' ${./app}/.firebaserc > "$out"/.firebaserc
    mkdir -p "$out"/.idx
    sed 's/<project-id>/${projectId}/' ${./dev.nix} > "$out/.idx/dev.nix"
  '';
}