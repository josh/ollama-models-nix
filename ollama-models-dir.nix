{
  lib,
  callPackage,
  symlinkJoin,
  models ? [ ],
}:
let
  lookupModel =
    model:
    if lib.attrsets.isDerivation model then
      model
    else
      let
        parts = lib.strings.splitString ":" model;
        len = builtins.length parts;
      in
      callPackage ./ollama-model.nix {
        model = builtins.elemAt parts 0;
        tag = if len == 2 then (builtins.elemAt parts 1) else "latest";
      };

in
symlinkJoin {
  name = "ollama-models";
  paths = builtins.map lookupModel models;
}
