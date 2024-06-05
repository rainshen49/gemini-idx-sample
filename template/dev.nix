# This will become the user's IDX nix config
{ pkgs, ... }: {
  channel = "unstable"; # "stable-23.05" or "unstable"
  # Use https://search.nixos.org/packages to  find packages
  packages = [
    pkgs.nodejs
  ];
  # Sets environment variables in the workspace
  env = {
    GOOGLE_PROJECT = "<project-id>";
  };

  idx = {
    # search for the extension on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      # "vscodevim.vim"
    ];
    workspace = {
      # runs when a workspace is first created with this `dev.nix` file
      # to run something each time the environment is rebuilt, use the `onStart` hook
      onCreate = {
        npm-install = "npm install";
      };

      onStart = {
        firebase-setup = "firebase login && firebase use <project-id>";
      };
    };
    # preview configuration, identical to monospace.json
    previews = {
      enable = true;
      previews = [
        {
          command = [
            "npm"
            "run"
            "dev"
            "--"
            "--port"
            "$PORT"
          ];
          id = "web";
          manager = "web";
        }
      ];
    };
  };
}
