{
  lib,
  callPackage,
  registry ? "registry.ollama.ai",
  modelNamespace ? "library",
}:
let
  mkModel =
    model: tag:
    callPackage ./ollama-model.nix {
      inherit
        registry
        modelNamespace
        model
        tag
        ;
    };

  models = builtins.attrNames (builtins.readDir ./manifests/${registry}/${modelNamespace});

  orderTags =
    tags:
    let
      hasLatest = (lib.lists.findFirstIndex (tag: tag == "latest") null tags) != null;
      withoutLatest = lib.lists.remove "latest" tags;
    in
    if hasLatest then ([ "latest" ] ++ withoutLatest) else tags;

  readTags =
    model:
    orderTags (
      builtins.attrNames (builtins.readDir ./manifests/${registry}/${modelNamespace}/${model})
    );

  mkModelCollection =
    model:
    let
      tags = readTags model;
      firstTag = builtins.head tags;
    in
    {
      name = lib.strings.replaceStrings [ "." ] [ "_" ] model;
      value =
        (mkModel model firstTag)
        // (lib.genAttrs tags (mkModel model))
        // {
          recurseForDerivations = true;
        };
    };

in

builtins.listToAttrs (builtins.map mkModelCollection models)
