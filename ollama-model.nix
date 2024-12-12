{
  lib,
  fetchurl,
  stdenvNoCC,
  registry ? "registry.ollama.ai",
  modelNamespace ? "library",
  model,
  tag ? "latest",
}:
let
  modelParts = lib.strings.splitString ":" model;
  modelHasTag = builtins.length modelParts == 2;

  meta =
    if modelHasTag then
      assert lib.asserts.assertMsg (
        tag == "latest"
      ) "'${model}' already has a tag, but '${tag}' was given";
      {
        model = builtins.elemAt modelParts 0;
        tag = builtins.elemAt modelParts 1;
      }
    else
      {
        inherit model tag;
      };

  qualifiedModel = "${modelNamespace}/${meta.model}";
  manifestPath = ./manifests/${registry}/${qualifiedModel}/${meta.tag}.json;
  manifest = builtins.fromJSON (builtins.readFile manifestPath);

  fetchblob =
    sha256:
    fetchurl {
      name = "sha256-${sha256}";
      url = "https://${registry}/v2/${qualifiedModel}/blobs/sha256:${sha256}";
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

stdenvNoCC.mkDerivation {
  name = "ollama-model-${meta.model}-${meta.tag}";

  buildCommand = ''
    mkdir -p $out/manifests/${registry}/${qualifiedModel} $out/blobs
    cp ${manifestPath} $out/manifests/${registry}/${qualifiedModel}/${meta.tag}
    ${builtins.concatStringsSep "\n" blobs}
  '';
  passAsFile = [ "buildCommand" ];

  meta = meta // {
    homepage = "https://ollama.com/library/${meta.model}:${meta.tag}";
    platforms = lib.platforms.all;
  };
}
