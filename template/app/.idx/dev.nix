# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "unstable"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.firebase-tools
    pkgs.terraform
    pkgs.dart
  ];

  # Sets environment variables in the workspace
  env = {
    GOOGLE_PROJECT = "<project-id>";
    CLOUDSDK_CORE_PROJECT = "<project-id>";
    TF_VAR_project = "<project-id>";
  };

  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
      "hashicorp.terraform"
    ];

    # Enable previews
    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            ".idx/flutter/bin/flutter"
            "run"
            "--dart-define-from-file"
            "env.json"
            "--machine"
            "-d"
            "web-server"
            "--web-hostname"
            "0.0.0.0"
            "--web-port"
            "$PORT"
          ];

          manager = "flutter";
        };
      };
    };

    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        terraform = "terraform init --upgrade";
        flutter-sdk = ''echo "PATH=$PATH:$PWD/.idx/flutter/bin" >> ~/.bashrc'';
      };
      # Runs when the workspace is (re)started
      onStart = {
        bootstrap = "bash bootstrap.sh";
      };
    };
  };
}
