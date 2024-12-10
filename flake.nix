{
  description = "Ollama models";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      models = builtins.attrNames (builtins.readDir ./manifests/registry.ollama.ai/library);
    in
    {
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          modelTags =
            model: builtins.attrNames (builtins.readDir ./manifests/registry.ollama.ai/library/${model});
          mkModel = model: tag: pkgs.callPackage ./model.nix { inherit model tag; };
          mkModelCollection =
            model:
            (mkModel model "latest")
            // (lib.genAttrs (modelTags model) (mkModel model))
            // {
              recurseForDerivations = true;
            };
        in
        (builtins.listToAttrs (
          builtins.map (model: {
            name = lib.strings.replaceStrings [ "." ] [ "_" ] model;
            value = mkModelCollection model;
          }) models
        ))
        // {
          update-manifests = pkgs.writeShellApplication {
            name = "update-manifests";
            runtimeInputs = with pkgs; [
              bash
              coreutils
              curl
            ];
            text = ''exec ${./update-manifests.bash} "$@"'';
          };
          discover-manifests = pkgs.writeShellApplication {
            name = "discover-manifests";
            runtimeInputs = with pkgs; [
              bash
              coreutils
              curl
              htmlq
            ];
            text = ''exec ${./discover-manifests.bash} "$@"'';
          };
        }
      );
    };
}
