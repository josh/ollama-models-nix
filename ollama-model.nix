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
  validateModelTag =
    { model, tag }:
    let
      parts = lib.strings.splitString ":" model;
      model' = builtins.elemAt parts 0;
      tag' = builtins.elemAt parts 1;
      modelHasTag = builtins.length parts == 2;
    in
    if modelHasTag then
      assert lib.asserts.assertMsg (
        tag == "latest"
      ) "'${model}' already has a tag, but '${tag}' was given";
      {
        model = model';
        tag = tag';
      }
    else
      {
        model = model;
        tag = tag;
      };

  id = validateModelTag { inherit model tag; };

  manifestPath = ./manifests/${registry}/${modelNamespace}/${id.model}/${id.tag}.json;
  manifest = builtins.fromJSON (builtins.readFile manifestPath);

  fetchblob =
    sha256:
    fetchurl {
      name = "sha256-${sha256}";
      url = "https://${registry}/v2/${modelNamespace}/${id.model}/blobs/sha256:${sha256}";
      inherit sha256;
    };

  linkblobs =
    blobs:
    builtins.map (
      blob:
      let
        sha256 = lib.strings.removePrefix "sha256:" blob.digest;
        file = fetchblob sha256;
      in
      ''ln -s ${file} $out/blobs/${file.meta.name}''
    ) blobs;

  blobs = linkblobs ([ manifest.config ] ++ manifest.layers);
in

runCommand "ollama-model-${id.model}-${id.tag}"
  {
    meta = {
      model = id.model;
      tag = id.tag;
      homepage = "https://ollama.com/library/${id.model}:${id.tag}";
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out/manifests/${registry}/${modelNamespace}/${id.model} $out/blobs
    cp ${manifestPath} $out/manifests/${registry}/${modelNamespace}/${id.model}/${id.tag}
    ${builtins.concatStringsSep "\n" blobs}
  ''
