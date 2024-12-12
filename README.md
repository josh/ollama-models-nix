# ollama-models-nix

An `ollama` already exists upstream in nixpkgs. This repository provides locked models from the [Ollama registry](https://ollama.com/search) that can be used with the `OLLAMA_MODELS` environment variable. Models will be loaded from you Nix store rather than lazily downloaded.

## Usage

```sh
export OLLAMA_MODELS=$(nix build --print-out-paths github:josh/ollama-models-nix#llama3_2.3b)
ollama serve
```

Multiple models can easily be merged into a single directory using [nixpkgs](https://github.com/NixOS/nixpkgs) `symlinkJoin`.

```nix
let
  ollama-models-flake = builtins.getFlake "github:josh/ollama-models-nix";
  pkgs = import <nixpkgs> {
    overlays = [ ollama-models-flake.overlays.default ];
  };
in
pkgs.symlinkJoin {
  name = "ollama-models";
  paths = with pkgs.ollama-models; [ llama3_1 llama3_2 ];
}
```

or using by overriding the `ollama-models` package.

```nix
let
  ollama-models-flake = builtins.getFlake "github:josh/ollama-models-nix";
  pkgs = import <nixpkgs> {
    overlays = [ ollama-models-flake.overlays.default ];
  };
in
pkgs.ollama-models.override {
  models = [ "llama3.1" "llama3.2:3b" ];
}
```
