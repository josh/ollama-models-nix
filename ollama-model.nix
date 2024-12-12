{
  lib,
  fetchurl,
  runCommand,
  registry ? "registry.ollama.ai",
  modelNamespace ? "library",
  model,
  tag ? "latest",
}:
let
  modelPath = ./manifests/${registry}/${modelNamespace}/${model};

  fallbackTag = builtins.head (builtins.attrNames (builtins.readDir modelPath));
  tagExists = builtins.pathExists "${modelPath}/${tag}";
  tag' =
    if tag == "latest" && !tagExists then
      (lib.trivial.warn "${model}:latest not found, using ${model}:${fallbackTag}" fallbackTag)
    else
      tag;

  manifestPath = ./manifests/${registry}/${modelNamespace}/${model}/${tag'};
  manifest = builtins.fromJSON (builtins.readFile manifestPath);

  fetchblob =
    { model, sha256 }:
    fetchurl {
      name = "sha256-${sha256}";
      url = "https://${registry}/v2/${modelNamespace}/${model}/blobs/sha256:${sha256}";
      inherit sha256;
    };

  linkblobs =
    blobs:
    builtins.map (
      blob:
      let
        sha256 = lib.strings.removePrefix "sha256:" blob.digest;
        file = fetchblob { inherit model sha256; };
      in
      ''ln -s ${file} $out/blobs/${file.meta.name}''
    ) blobs;

  blobs = linkblobs ([ manifest.config ] ++ manifest.layers);
in

runCommand "ollama-model-${model}-${tag'}"
  {
    meta = {
      inherit model;
      tag = tag';
      homepage = "https://ollama.com/library/${model}:${tag'}";
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out/manifests/${registry}/${modelNamespace}/${model} $out/blobs
    cp ${manifestPath} $out/manifests/${registry}/${modelNamespace}/${model}/${tag'}
    ${builtins.concatStringsSep "\n" blobs}
  ''
