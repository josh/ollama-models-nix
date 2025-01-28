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
        (import ./ollama-models-pkgs.nix {
          inherit lib;
          inherit (pkgs) callPackage;
        })
        // {
          default = self.packages.${system}.models;

          models = pkgs.callPackage ./ollama-models-dir.nix { };
          ollama = pkgs.callPackage ./ollama.nix { };

          update-manifests = pkgs.writeShellApplication {
            name = "update-manifests";
            runtimeInputs = with pkgs; [
              bash
              coreutils
              curl
              htmlq
              jq
            ];
            text = ''exec ${./update-manifests.bash} "$@"'';
          };
        }
      );

      checks = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
          tiny-models = [
            "nomic-embed-text"
            "qwen2:0.5b"
          ];
        in
        {
          packages-models = self.packages.${system}.models.override {
            models = tiny-models;
          };
          overlay-models = pkgs.ollama-models.override {
            models = tiny-models;
          };
          packages-ollama = self.packages.${system}.ollama.override {
            models = tiny-models;
          };
        }
      );
    };
}
