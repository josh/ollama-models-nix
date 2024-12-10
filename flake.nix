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
          mkModel = model: tag: callPackage ./model.nix { inherit model tag; };
          mkModelCollection =
            model: tags:
            (mkModel model "latest")
            // (lib.genAttrs tags (mkModel model))
            // ({ recurseForDerivations = true; });
        in
        (lib.attrsets.mapAttrs' (model: tags: {
          name = lib.strings.replaceStrings [ "." ] [ "_" ] model;
          value = mkModelCollection model tags;
        }) models)
        // {
          update-manifests = callPackage ./update.nix { };
        }
      );
    };
}
