{
  description = "Ollama models";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      models = builtins.fromJSON (builtins.readFile ./manifests/models.json);
    in
    {
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          callPackage = pkgs.callPackage;
        in
        lib.attrsets.mapAttrs' (model: tags: {
          name = lib.strings.replaceStrings [ "." ] [ "_" ] model;
          value = callPackage ./model-collection.nix {
            inherit model tags;
          };
        }) models
      );
    };
}
