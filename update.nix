{
  writeShellApplication,
  curl,
}:
writeShellApplication {
  name = "update-manifests";
  runtimeInputs = [ curl ];
  runtimeEnv = {
    OLLAMA_REGISTRY = "registry.ollama.ai";
  };
  text = ''
    pull() {
      local model=$1
      local tag=$2
      local output=$3
      echo "+ pull $model:$tag"
      curl --fail \
        --location \
        --show-error \
        --silent \
        --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        "https://$OLLAMA_REGISTRY/v2/library/$model/manifests/$tag" \
        --create-dirs \
        --output "$output"
    }

    for model_path in "./manifests/$OLLAMA_REGISTRY/library/"*; do
      model=$(basename "$model_path")
      for tag_path in "$model_path"/*; do
        tag=$(basename "$tag_path")
        pull "$model" "$tag" "$tag_path"
      done
    done
  '';
}
