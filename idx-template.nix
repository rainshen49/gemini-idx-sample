{ pkgs, projectId, ... }: {
  bootstrap = ''
    cp -rf ${./.}/app "$WS_NAME"
    chmod -R +w "$WS_NAME"
    sed 's/<project-id>/${projectId}/' app/.firebaserc.template > app/.firebaserc
    mv "$WS_NAME" "$out"
  '';
}