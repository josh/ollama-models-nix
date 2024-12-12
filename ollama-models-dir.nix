{
  pkgs,
  lib,
  callPackage,
  symlinkJoin,
  models ? [ ],
}:
let
  lib' = import ./lib.nix { inherit lib; };
  lookupModel = lib'.lookupModel pkgs;
in
symlinkJoin {
  name = "ollama-models";
  paths = builtins.map lookupModel models;
}
