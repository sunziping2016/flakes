{
  packages = pkgs: {
    terraform-providers = {
      inherit (pkgs.terraform-providers) authentik ldap;
    };
    inherit (pkgs) ossfs seafile-pro-server seahub-pro;
    python311Packages = {
      inherit (pkgs.python3Packages) seaserv-pro;
    };
  };
  overlay = self: super:
    let
      sources = self.callPackages (import ./_sources/generated.nix) { };
    in
    {
      terraform-providers = super.terraform-providers // {
        authentik = self.callPackage ./terraform-provider-authentik { };
        ldap = self.callPackage ./terraform-provider-ldap { };
      };
      ossfs = self.callPackage ./ossfs { };
      seafile-pro-server = self.callPackage ./seafile-pro-server { inherit (super) seafile-server; };
      python311 = super.python311.override {
        packageOverrides = py-self: py-super: {
          seaserv-pro = py-self.toPythonModule self.seafile-pro-server;
        };
      };
    };
}
