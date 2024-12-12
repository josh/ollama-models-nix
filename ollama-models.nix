{
  lib,
  callPackage,
}:
let
  lib' = import ./lib.nix { inherit lib; };

  mkModelCollection =
    model:
    let
      tags = lib'.readTags model;
      firstTag = builtins.head tags;
      mkModel =
        tag:
        callPackage ./ollama-model.nix {
          inherit model tag;
        };
    in
    {
      name = lib.strings.replaceStrings [ "." ] [ "_" ] model;
      value =
        (mkModel firstTag)
        // (lib.genAttrs tags mkModel)
        // {
          recurseForDerivations = true;
        };
    };

in

builtins.listToAttrs (builtins.map mkModelCollection lib'.modelNames)
