{
  lib,
  callPackage,
  writeShellApplication,
  ollama,
  models ? [ ],
}:
writeShellApplication {
  name = "ollama";
  runtimeEnv = {
    OLLAMA_MODELS = callPackage ./ollama-models-dir.nix { inherit models; };
  };
  text = ''
    exec -a "$0" ${lib.getExe ollama} "$@"
  '';
}
