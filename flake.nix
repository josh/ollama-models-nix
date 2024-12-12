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
      orderTags =
        tags:
        let
          hasLatest = (lib.lists.findFirstIndex (tag: tag == "latest") null tags) != null;
          withoutLatest = lib.lists.remove "latest" tags;
        in
        if hasLatest then ([ "latest" ] ++ withoutLatest) else tags;
      modelTags =
        model:
        orderTags (builtins.attrNames (builtins.readDir ./manifests/registry.ollama.ai/library/${model}));
    in
    {
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mkModel = model: tag: pkgs.callPackage ./ollama-model.nix { inherit model tag; };
          mkModelCollection =
            model:
            let
              tags = modelTags model;
              firstTag = builtins.head tags;
              mkModel' = mkModel model;
            in
            (mkModel' firstTag)
            // (lib.genAttrs tags mkModel')
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
              jq
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
