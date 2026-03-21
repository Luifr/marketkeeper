{
  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs (nixpkgs.lib.systems.flakeExposed) (
          system:
          f {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      devShell = forAllSystems ({ pkgs, ... }: pkgs.mkShell {
        buildInputs = [
            pkgs.lua-language-server
            pkgs.love
            pkgs.tree-sitter
        ];
      });
    };
}