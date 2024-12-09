{
  lib,
  callPackage,
  runCommand,
  registry ? "registry.ollama.ai",
  model,
  tag ? "latest",
  manifestPath ? ./manifests/${registry}/library/${model}/${tag},
}:
let
  manifest = builtins.fromJSON (builtins.readFile manifestPath);

  linkBlobs =
    blobs:
    builtins.map (
      blob:
      let
        sha256 = lib.strings.removePrefix "sha256:" blob.digest;
        file = callPackage ./blob.nix {
          inherit registry model sha256;
        };
      in
      ''ln -s ${file} $out/blobs/sha256-${sha256}''
    ) blobs;

  blobs = linkBlobs ([ manifest.config ] ++ manifest.layers);
in

runCommand "ollama-model-${model}-${tag}" { } ''
  mkdir -p $out/manifests/${registry}/library/${model} $out/blobs
  cp ${manifestPath} $out/manifests/${registry}/library/${model}/${tag}
  ${builtins.concatStringsSep "\n" blobs}
''

# TODO: Set safe pname metadata
# Set version metadata
