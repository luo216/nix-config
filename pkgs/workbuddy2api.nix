{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchurl,
}:
let
  inherit (python3Packages) buildPythonPackage;

  # Not packaged in nixpkgs yet; both are pure-Python wheels published on PyPI.
  buddy-agent-auth = buildPythonPackage {
    pname = "buddy-agent-auth";
    version = "0.1.1";
    format = "wheel";

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/59/e9/dca92e0c20d9e7f033c04e0cbeb6f19f54e16b73d63fcd8b6a12718a7f50/buddy_agent_auth-0.1.1-py3-none-any.whl";
      hash = "sha256-IgQjGEIfd5OQ4GFY4fG+ZqsxiGDXYuuvT7UQA7WIcE8=";
    };

    dependencies = with python3Packages; [
      httpx
      cryptography
    ];

    meta = {
      description = "Auth helpers for CodeBuddy/Trae clients";
      homepage = "https://github.com/hawklithm/workbuddy2api";
      license = lib.licenses.mit;
    };
  };

  buddy-agent-checkin = buildPythonPackage {
    pname = "buddy-agent-checkin";
    version = "0.1.2";
    format = "wheel";

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/4c/92/0788d435ef8e45324d2cfab083f8b1ca04b97a75900d59185443f4bb1ef7/buddy_agent_checkin-0.1.2-py3-none-any.whl";
      hash = "sha256-KVL9OY0uDPCn8rRHB1SYUNzdhgTHEpj9KkO6sbeosUQ=";
    };

    dependencies = with python3Packages; [
      buddy-agent-auth
      fastapi
      httpx
    ];

    meta = {
      description = "Daily check-in helpers for CodeBuddy/Trae";
      homepage = "https://github.com/hawklithm/workbuddy2api";
      license = lib.licenses.mit;
    };
  };
in
  python3Packages.buildPythonApplication rec {
    pname = "workbuddy2api";
    version = "2.0.8";

    src = fetchFromGitHub {
      owner = "hawklithm";
      repo = "workbuddy2api";
      rev = "34a31c3bf2a8652422d4404cb299f4865e763781";
      hash = "sha256-oyi2MksdGa4KDjT7tcRhywIhBoGkgQX8xtNnvH5HGmo=";
    };

    pyproject = true;
    build-system = [python3Packages.setuptools];

    dependencies = with python3Packages; [
      fastapi
      uvicorn
      httpx
      socksio
      requests
      cryptography
      buddy-agent-auth
      buddy-agent-checkin
    ];

    # The test suite drives a real upstream login flow.
    doCheck = false;

    meta = with lib; {
      description = "Local OpenAI/Responses/Anthropic compatible proxy for CodeBuddy";
      homepage = "https://github.com/hawklithm/workbuddy2api";
      license = licenses.mit;
      platforms = platforms.unix;
      mainProgram = "workbuddy2api";
    };
  }
