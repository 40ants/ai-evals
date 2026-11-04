let
  revision = "aad8c5b2da5fb5e63eadcb8075b0682e6baee7b7";
  engine = builtins.fetchGit {
    url = "https://github.com/40ants/ai-evals.git";
    rev = revision;
  };
in import (engine + "/shell.nix") {
  projectRoot = toString ./.;
  engineRevision = revision;
}
