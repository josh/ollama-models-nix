{
  lib,
  callPackage,
}:
let
  modelNames = builtins.attrNames (builtins.readDir ./manifests/registry.ollama.ai/library);

  mkModelCollection =
    model:
    let
      modelPath = ./manifests/registry.ollama.ai/library/${model};
      tags = builtins.map (lib.strings.removeSuffix ".json") (
        builtins.attrNames (builtins.readDir modelPath)
      );
      mkModel =
        tag:
        callPackage ./ollama-model.nix {
          inherit model tag;
        };
    in
    {
      name = lib.strings.replaceStrings [ "." ] [ "_" ] model;
      value =
        (mkModel "latest")
        // (lib.genAttrs tags mkModel)
        // {
          recurseForDerivations = true;
        };
    };

in

builtins.listToAttrs (builtins.map mkModelCollection modelNames)
