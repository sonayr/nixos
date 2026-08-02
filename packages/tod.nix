{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "tod";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "tod-org";
    repo = "tod";
    rev = "v${version}";
    hash = "sha256-v4ystaqeMUprJbCimaTvtcfAxY7jqp6jjDmUfmPPdOM=";
  };

  cargoHash = "sha256-LU+Tk6pf1x/sbMuTxP+IcO5FpeoZR+pA/GTqmTbBIxA=";

  meta = with lib; {
    description = "An unofficial Todoist command line client written in Rust";
    homepage = "https://github.com/tod-org/tod";
    license = licenses.mit;
    mainProgram = "tod";
  };
}