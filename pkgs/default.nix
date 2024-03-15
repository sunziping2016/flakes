{
  packages = pkgs: {
    terraform-providers = {
      inherit (pkgs.terraform-providers) authentik ldap;
    };
    inherit (pkgs) ossfs nixos-kexec-installer-noninteractive;
  };
  overlay = self: super: {
    terraform-providers = super.terraform-providers // {
      authentik = self.callPackage ./terraform-provider-authentik { };
      ldap = self.callPackage ./terraform-provider-ldap { };
    };
    ossfs = self.callPackage ./ossfs { };
    nixos-kexec-installer-noninteractive = self.fetchurl {
      url = "https://github.com/nix-community/nixos-images/releases/download/nixos-23.11/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz";
      sha256 = "0zscpngvwdlhmlzazdprfws001mn0nyzxxxxl6gfwn8h531ngv0f";
    };
  };
}
