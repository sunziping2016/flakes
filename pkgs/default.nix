{
  packages = pkgs: {
    terraform-providers = {
      inherit (pkgs.terraform-providers) authentik;
    };
  };
  overlay = self: super: {
    terraform-providers = super.terraform-providers // {
      authentik = self.callPackage ./terraform-provider-authentik { };
    };
  };
}
