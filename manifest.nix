let
  pkgs = import <nixpkgs> {};

  writeShellApplication = pkgs.writeShellApplication;
  curl = pkgs.curl;

  registry = "registry.ollama.ai";
in
writeShellApplication {
  name = "fetch-manifest";
  runtimeInputs = [ curl ];
  runtimeEnv = {
    REGISTRY = registry;
  };
  text = ''
    set -o xtrace
    IFS=':' read -r MODEL TAG <<< "$1"
    mkdir -p "./manifests/$REGISTRY/$MODEL"
    curl --fail \
        --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        "https://$REGISTRY/v2/library/$MODEL/manifests/$TAG" \
        --output "./manifests/$REGISTRY/library/$MODEL/$TAG"
  '';
}
