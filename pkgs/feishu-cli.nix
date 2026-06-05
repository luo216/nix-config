{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "feishu-cli";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ztxtxwd";
    repo = "feishu-cli";
    rev = "v${version}";
    hash = "sha256-fQ0RkDrJSpfOXrHPngyhfnjn9SJ3lmvQmA/zM0UtEuM=";
  };

  npmDepsHash = "sha256-PuoEwi9bqbWyQSs1+Rlz03IK9Gg8SLSnkBmgw6xIysY=";

  buildPhase = ''
    runHook preBuild
    npx tsc
    runHook postBuild
  '';

  meta = with lib; {
    description = "Feishu CLI - multi-account credential management";
    homepage = "https://github.com/ztxtxwd/feishu-cli";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "feishu";
  };
}
