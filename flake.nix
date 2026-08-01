{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = ["aarch64-darwin" "x86_64-linux"];
    eachSystem = function:
      nixpkgs.lib.genAttrs systems (system:
        function {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
        });
  in {
    devShells = eachSystem ({pkgs, ...}: {
      default = pkgs.mkShellNoCC {
        packages = [
          pkgs.pnpm_11
          pkgs.nodejs_24

          pkgs.tailwindcss-language-server
          pkgs.typescript-language-server
          pkgs.vscode-langservers-extracted
          pkgs.astro-language-server
        ];
      };
    });

    packages = eachSystem ({pkgs, ...}: {
      default = pkgs.stdenv.mkDerivation (finalAttrs: {
        src = pkgs.lib.cleanSource ./.;
        pname = "nkoll.de";
        version = "0.0.0";

        nativeBuildInputs = with pkgs; [
          nodejs_24
          pnpm_11
          pnpmConfigHook
        ];

        pnpmDeps = pkgs.fetchPnpmDeps {
          inherit (finalAttrs) pname version src;
          fetcherVersion = 4;
          hash = "sha256-B5dIM+j5kaxzQV1IU/3zo+e332YxASKBzNercNFTPm8=";
        };
        buildPhase = ''
          runHook preBuild

          export NODE_ENV=production
          export CI=1
          pnpm run build

          runHook preBuild
        '';

        installPhase = ''
          mv dist $out
        '';
      });
    });
  };
}
