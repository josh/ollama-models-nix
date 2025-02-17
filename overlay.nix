final: prev:
let
  models = import ./ollama-models-pkgs.nix {
    inherit (final) lib callPackage;
  };
  model-dir = final.callPackage ./ollama-models-dir.nix { };
in
{
  ollama-models = model-dir // models;
  ollama-models-wrapped = final.callPackage ./ollama.nix { };
}
