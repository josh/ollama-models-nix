final: prev:
let
  models = import ./ollama-models.nix {
    lib = final.lib;
    callPackage = final.callPackage;
  };
  model-dir = final.callPackage ./ollama-models-dir.nix { };
in
{
  ollama-models = model-dir // models;
  ollama-models-wrapped = final.callPackage ./ollama.nix { };
}
