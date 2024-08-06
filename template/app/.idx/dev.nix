# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: 
let
  flutter_sdk = pkgs.fetchzip {
    url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.3-stable.tar.xz";
    sha256 = "sha256-rLglM2KIsgrjddNgdFbJiOCgKQQQFFUuPMP6bpZCEx8=";
  };
  in
{
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
            ".flutter/bin/flutter"
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
        flutter-sdk = ''
          rm -rf .flutter
          cp -rf ${flutter_sdk}/. .flutter
          echo "PATH=$PATH:$PWD/.flutter/bin" >> ~/.bashrc
        '';
      };
      # Runs when the workspace is (re)started
      onStart = {
        bootstrap = "bash bootstrap.sh";
      };
    };
  };
}
