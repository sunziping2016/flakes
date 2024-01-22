{
  packages = pkgs: {
    terraform-providers = {
      inherit (pkgs.terraform-providers) authentik;
    };
    inherit (pkgs) ossfs;
  };
  overlay = self: super: {
    terraform-providers = super.terraform-providers // {
      authentik = self.callPackage ./terraform-provider-authentik { };
    };
    ossfs = self.callPackage ./ossfs { };
  };
}
