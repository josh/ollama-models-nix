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
  system = builtins.currentSystem;
  pkgs = import <nixpkgs> { system = system; };
  ollama-models = (builtins.getFlake "github:josh/ollama-models-nix").packages.${system};
in
pkgs.symlinkJoin {
  name = "ollama-models";
  paths = with ollama-models; [ llama3_1 llama3_2 ];
}
```
