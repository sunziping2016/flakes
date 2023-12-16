{ pkgs, ... }:
{
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      withPython3 = true;
      withNodeJs = true;
      extraPackages = [ ];
      #-- Plugins --#
      plugins = with pkgs.vimPlugins; [ ];
      #-- --#
    };
  };

  home = {
    packages = with pkgs; [
      #-- tools --#
      ripgrep
      fd
      lazygit
      #-- lsp --#
      nixd
      lua-language-server
      #-- tree-sitter --#
      tree-sitter
      #-- format --#
      nixpkgs-fmt
      stylua
    ];
  };

  home.file.".config/nvim/init.lua".source = ./init.lua;
  home.file.".config/nvim/lua".source = ./lua;
}
