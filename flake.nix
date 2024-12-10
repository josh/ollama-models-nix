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
      models = builtins.attrNames (builtins.readDir ./manifests/registry.ollama.ai/library);
    in
    {
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          callPackage = pkgs.callPackage;
          modelTags =
            model: builtins.attrNames (builtins.readDir ./manifests/registry.ollama.ai/library/${model});
          mkModel = model: tag: callPackage ./model.nix { inherit model tag; };
          mkModelCollection =
            model:
            (mkModel model "latest")
            // (lib.genAttrs (modelTags model) (mkModel model))
            // ({ recurseForDerivations = true; });
        in
        (builtins.listToAttrs (
          builtins.map (model: {
            name = lib.strings.replaceStrings [ "." ] [ "_" ] model;
            value = mkModelCollection model;
          }) models
        ))
        // {
          update-manifests = callPackage ./update.nix { };
        }
      );
    };
}
