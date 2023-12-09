{ pkgs, ... }:
{
  programs.helix = {
    enable = true;

    settings.theme = "dracula";

    settings.editor = {
      auto-format = true;
      color-modes = true;
      completion-replace = true;
      completion-trigger-len = 0;
      cursor-shape.insert = "bar";
      cursorline = true;
      bufferline = "multiple";
      file-picker.hidden = false;
      idle-timeout = 200;
      line-number = "relative";
      text-width = 100;
    };

    settings.editor.indent-guides = {
      render = true;
      character = "▏";
    };

    settings.editor.whitespace = {
      render = "all";
    };

    languages = {
      language-server.nil = {
        command = "${pkgs.nil}/bin/nil";
        config.nil = {
          formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
        };
      };

      language-server.terraform-ls = {
        command = "${pkgs.terraform-ls}/bin/terraform-ls";
        config = {
          terraform.path = "${pkgs.opentofu}/bin/tofu";
        };
      };
    };
  };
}
