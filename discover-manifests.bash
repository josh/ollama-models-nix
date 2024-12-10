#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

models() {
  curl https://ollama.com/search | \
    htmlq 'a[href^="/library/"]' --attribute href | \
    sed 's/^\/library\///'
}

for model in $(models); do
  mkdir -p "manifests/registry.ollama.ai/library/$model"
  touch "manifests/registry.ollama.ai/library/$model/latest"
done

# TODO: Discover tags for each model
