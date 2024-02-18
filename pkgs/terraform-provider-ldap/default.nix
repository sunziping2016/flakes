{ buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "terraform-provider-ldap";
  version = "0.4.0";
  src = fetchFromGitHub {
    owner = "dodevops";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-gEGboqISfOpjOGY9yIs/be4vWJbH14f3plGvU08Gg2c=";
  };
  doCheck = false;
  vendorHash = "sha256-R5AvxuNeoQLFoMFhCRSzYv31qYBVsg3+xFGzyDGMYck=";

  postInstall = ''
    path="$out/libexec/terraform-providers/registry.terraform.io/dodevops/ldap/${version}/''${GOOS}_''${GOARCH}/"
    mkdir -p "$path"
    mv $out/bin/${pname} $path/${pname}_v${version}
    rmdir $out/bin
  '';
}
