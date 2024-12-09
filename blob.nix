{
  fetchurl,
  registry ? "registry.ollama.ai",
  model,
  sha256,
}:
fetchurl {
  url = "https://${registry}/v2/library/${model}/blobs/sha256:${sha256}";
  curlOptsList = [
    "--header"
    "Accept: application/vnd.docker.distribution.manifest.v2+json"
  ];
  sha256 = sha256;
}
