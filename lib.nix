{ lib }:
let
  modelNames = builtins.attrNames (builtins.readDir ./manifests/registry.ollama.ai/library);

  # Sort tags so that "latest" is always first
  sortTags =
    tags:
    let
      hasLatest = (lib.lists.findFirstIndex (tag: tag == "latest") null tags) != null;
      withoutLatest = lib.lists.remove "latest" tags;
    in
    if hasLatest then ([ "latest" ] ++ withoutLatest) else tags;

  # Get list of model tag names
  readTags =
    model:
    let
      modelPath = ./manifests/registry.ollama.ai/library/${model};
    in
    assert lib.asserts.assertMsg (builtins.pathExists modelPath) "Model ${model} not found";
    sortTags (builtins.attrNames (builtins.readDir modelPath));

  # Get the default tag for a model, usually "latest"
  readDefaultTag = model: builtins.head (readTags model);

  # Look up a model by string name like "llama3.2", "llama3.2:latest", "llama3.2:8b"
  lookupModel =
    pkgs: model:
    if lib.attrsets.isDerivation model then
      model
    else
      let
        parts = lib.strings.splitString ":" model;
        len = builtins.length parts;
      in
      pkgs.callPackage ./ollama-model.nix {
        model = builtins.elemAt parts 0;
        tag = if len == 2 then (builtins.elemAt parts 1) else (readDefaultTag model);
      };

  combineModels =
    pkgs: models:
    pkgs.symlinkJoin {
      name = "ollama-models";
      paths = builtins.map (model: lookupModel pkgs model) models;
    };

in
{
  inherit
    combineModels
    lookupModel
    modelNames
    readTags
    sortTags
    ;
}
