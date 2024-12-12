{
  lib,
  callPackage,
  symlinkJoin,
  models ? [ ],
}:
let
  # Look up a model by string name like "llama3.2", "llama3.2:latest", "llama3.2:8b"
  # Look up a model by string name like "llama3.2", "llama3.2:latest", "llama3.2:8b"
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
