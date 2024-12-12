{
  lib,
  callPackage,
  symlinkJoin,
  models ? [ ],
}:
let
  mkModel =
    model:
    if lib.attrsets.isDerivation model then
      model
    else
      callPackage ./ollama-model.nix { inherit model; };
in
symlinkJoin {
  name = "ollama-models";
  paths = builtins.map mkModel models;
}
