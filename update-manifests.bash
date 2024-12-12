#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

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
		"https://registry.ollama.ai/v2/library/$model/manifests/$tag" \
		--create-dirs \
		--output "$output"
	jq --sort-keys <"$output" >"${output}~"
	mv "${output}~" "$output"
}

pull_all() {
	for model_path in "./manifests/registry.ollama.ai/library/"*; do
		model=$(basename "$model_path")
		for tag_path in "$model_path"/*.json; do
			tag=$(basename "$tag_path" ".json")
			pull "$model" "$tag" "$tag_path"
		done
	done
}

MODEL="${1:-}"
TAG="${2:-latest}"

if [ -n "$MODEL" ]; then
	pull "$MODEL" "$TAG" "./manifests/registry.ollama.ai/library/$MODEL/$TAG.json"
else
	pull_all
fi
