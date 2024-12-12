final: prev: {
  ollama-models = import ./ollama-models.nix {
    lib = final.lib;
    callPackage = final.callPackage;
  };
}
