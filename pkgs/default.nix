{
  packages = pkgs: {
    terraform-providers = {
      inherit (pkgs.terraform-providers) authentik ldap;
    };
    inherit (pkgs) ossfs;
  };
  overlay = self: super: {
    terraform-providers = super.terraform-providers // {
      authentik = self.callPackage ./terraform-provider-authentik { };
      ldap = self.callPackage ./terraform-provider-ldap { };
    };
    ossfs = self.callPackage ./ossfs { };
  };
}
