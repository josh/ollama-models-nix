{
  lib,
  callPackage,
  registry ? "registry.ollama.ai",
  model,
  tags ? [ ],
}:
let
  mkModel = tag: callPackage ./model.nix { inherit registry model tag; };
in
(mkModel "latest") // (lib.genAttrs tags mkModel)

# TODO: Set safe pname metadata
