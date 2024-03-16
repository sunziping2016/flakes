{ inputs, ... }: {
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
    use-cgroups = true;
  };
}
