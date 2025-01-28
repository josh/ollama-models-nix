#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

HTML="$(curl --no-progress-meter https://ollama.com/search)"

models() {
  echo "$HTML" |
    htmlq 'a[href^="/library/"]' --attribute href |
    sed 's/^\/library\///'
}

model_has_latest_tag() {
  [ "$1" != "wizardlm" ]
}

tags() {
  if model_has_latest_tag "$1"; then
    echo "latest"
  fi
  echo "$HTML" |
    htmlq "a[href=\"/library/$1\"] > div:nth-child(2) > div:nth-child(1) > span.text-blue-600" --text
}

for model in $(models); do
  mkdir -p "manifests/registry.ollama.ai/library/$model"
  for tag in $(tags "$model"); do
    if [ -f "manifests/registry.ollama.ai/library/$model/$tag.json" ]; then
      continue
    fi
    touch "manifests/registry.ollama.ai/library/$model/$tag.json"
    if ! update-manifests "$model" "$tag"; then
      echo "Failed to update $model:$tag" >&2
      rm -f "manifests/registry.ollama.ai/library/$model/$tag.json"
    fi
  done
done
