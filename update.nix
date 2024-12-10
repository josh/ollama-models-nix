{
  lib,
  writeShellApplication,
  curl,
}:
let
  registry = "registry.ollama.ai";
  models = builtins.fromJSON (builtins.readFile ./manifests/models.json);

  fetchManifestCommand = name: tag: ''
    curl --fail \
      --location \
      --show-error \
      --silent \
      --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
      "https://${registry}/v2/library/${name}/manifests/${tag}" \
      --create-dirs \
      --output "./manifests/${registry}/library/${name}/${tag}"
  '';

  cmds = lib.lists.flatten (
    lib.attrsets.mapAttrsToList (
      name: tags: builtins.map (tag: fetchManifestCommand name tag) ([ "latest" ] ++ tags)
    ) models
  );
in
writeShellApplication {
  name = "update-manifests";
  runtimeInputs = [ curl ];
  text =
    ''
      set -o xtrace
    ''
    + (builtins.concatStringsSep "\n" cmds);
}
