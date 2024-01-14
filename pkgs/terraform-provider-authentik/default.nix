{ buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "terraform-provider-authentik";
  version = "2023.10.0";
  src = fetchFromGitHub {
    owner = "goauthentik";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-eyWpssvYe3KKr2vfMRBfE4W1xrZZFeP55VmAQoitamc=";
  };
  doCheck = false;
  vendorHash = "sha256-aDExL3uFLhCqFibrepb2zVOJ7aW5CWjuqtx73w7p1qc=";

  postInstall = ''
    path="$out/libexec/terraform-providers/registry.terraform.io/goauthentik/authentik/${version}/''${GOOS}_''${GOARCH}/"
    mkdir -p "$path"
    mv $out/bin/${pname} $path/${pname}_v${version}
    rmdir $out/bin
  '';
}
