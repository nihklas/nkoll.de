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
          pkgs.pnpm
          pkgs.nodejs

          pkgs.typescript-language-server
          pkgs.vscode-langservers-extracted
          pkgs.astro-language-server
        ];
      };
    });
  };
}
