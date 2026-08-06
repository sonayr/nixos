{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl, cacert }:

rustPlatform.buildRustPackage rec {
  pname = "tod";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "tod-org";
    repo = "tod";
    rev = "v${version}";
    hash = "sha256-v4ystaqeMUprJbCimaTvtcfAxY7jqp6jjDmUfmPPdOM=";
  };

  cargoLock = { lockFile = ./Cargo.lock; };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  nativeCheckInputs = [ cacert ];

  preCheck = ''
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt";
    export HOME="$TMPDIR";
  '';

  cargoTestFlags = [ "--" "--skip" "buffer_redirect_tests_cannot_run_in_parallel" ];

  meta = with lib; {
    description = "An unofficial Todoist command line client written in Rust";
    homepage = "https://github.com/tod-org/tod";
    license = licenses.mit;
    mainProgram = "tod";
  };
}
