{
  lib,
  writeShellApplication,
  ollama,
}:
writeShellApplication {
  name = "ollama";
  runtimeEnv = {
    OLLAMA_MODELS = "TK";
  };
  text = ''
    exec -a "$0" ${lib.getExe ollama} "$@"
  '';
}
