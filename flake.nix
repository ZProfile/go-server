{
  description = "Go server for ZProfile";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    devenv-root,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        devenv.shells.default = {
          name = "Go server for ZProfile";
          languages.go.enable = true;

          services.keycloak = {
            enable = true;
            initialAdminPassword = "admin";
            sslCertificate = null;
            sslCertificateKey = null;
            realms.zprofile = {
              path = "./keycloak/realms/zprofile.json";
              import = true;
              export = true;
            };
            settings = {
              hostname = "localhost";
              http-port = 8080;
              http-enabled = true;
            };
          };

          # NOTE: First do devenv shell
          git-hooks.hooks = {
            actionlint = {
              enable = true;
              excludes = ["docker-publish.yaml"];
            };
          };

          devenv.root = let
            devenvRootFileContent = builtins.readFile devenv-root.outPath;
          in
            pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

          packages = with pkgs; [
            sops
          ];
        };
      };
    };
}
