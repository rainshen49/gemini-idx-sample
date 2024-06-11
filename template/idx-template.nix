{pkgs, projectId, apiKey, ...}: {
  bootstrap = ''
    mkdir -p "$out"
    cp -rf ${./app}/. "$out"
    chmod -R +w "$out"
    sed 's/<project-id>/${projectId}/' ${./app}/.firebaserc > "$out"/.firebaserc
    mkdir -p "$out"/.idx
    sed -e 's/<project-id>/${projectId}/' -e 's/<api-key>/${apiKey}/' ${./dev.nix} > "$out/.idx/dev.nix"
  '';
}