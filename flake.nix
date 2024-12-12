{
  description = "Ollama models";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      overlays.default = import ./overlay.nix;

      packages = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
        in
        pkgs.ollama-models
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
