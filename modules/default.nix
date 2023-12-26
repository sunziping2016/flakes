{
  nixosModules.default = import ./default;
  homeManagerModules.nvim = import ./nvim;
}
