{ buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "terraform-provider-authentik";
  version = "2024.2.0";
  src = fetchFromGitHub {
    owner = "goauthentik";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0/TIzaMgH3XoKcqugwmXxIZ5JAEfCkPlEwRYt5t7tpw=";
  };
  doCheck = false;
  vendorHash = "sha256-an5pTo/SPG6zETHT6KJK73GmZUdTEDlr4GUtHH2cpk0=";

  postInstall = ''
    path="$out/libexec/terraform-providers/registry.terraform.io/goauthentik/authentik/${version}/''${GOOS}_''${GOARCH}/"
    mkdir -p "$path"
    mv $out/bin/${pname} $path/${pname}_v${version}
    rmdir $out/bin
  '';
}
