{ lib, stdenv, fetchurl }:

let
  arch =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "amd64"
    else if stdenv.hostPlatform.system == "aarch64-linux" then
      "arm64"
    else
      throw "Unsupported system: ${stdenv.hostPlatform.system}";

  hashes = {
    x86_64-linux = "sha256-rl6K3XiEsFMdZrvKRXDR3kkf9tpR5Ovn6xYM3yQdnkI=";
    aarch64-linux = "sha256-K3IDtPsLoooMHhL4hVziwl920mao1e2vrFVAtoEqz/Y=";
  };
in
stdenv.mkDerivation rec {
  pname = "cloudflared";
  version = "2026.10.4";

  src = fetchurl {
    url = "https://github.com/cloudflare/cloudflared/releases/download/${version}/cloudflared-linux-${arch}";
    hash = hashes.${stdenv.hostPlatform.system};
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/bin/cloudflared
  '';

  meta = with lib; {
    description = "Cloudflare Tunnel client daemon";
    homepage = "https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "cloudflared";
  };
}
