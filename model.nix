{
  lib,
  callPackage,
  fetchurl,
  runCommand,
  registry ? "registry.ollama.ai",
  model,
  tag ? "latest",
  manifestPath ? ./manifests/${registry}/library/${model}/${tag},
}:
let
  manifest = builtins.fromJSON (builtins.readFile manifestPath);

  fetchblob =
    { model, sha256 }:
    fetchurl {
      name = "sha256-${sha256}";
      url = "https://${registry}/v2/library/${model}/blobs/sha256:${sha256}";
      curlOptsList = [
        "--header"
        "Accept: application/vnd.docker.distribution.manifest.v2+json"
      ];
      sha256 = sha256;
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

runCommand "ollama-model-${model}-${tag}"
  {
    meta = {
      model = model;
      tag = tag;
      homepage = "https://ollama.com/library/${model}:${tag}";
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out/manifests/${registry}/library/${model} $out/blobs
    cp ${manifestPath} $out/manifests/${registry}/library/${model}/${tag}
    ${builtins.concatStringsSep "\n" blobs}
  ''
