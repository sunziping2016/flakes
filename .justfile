set positional-arguments := true

default:
    @just --choose

apply-local:
    nixos-rebuild switch --flake "git+file://$(pwd)#desktop" --use-remote-sudo --show-trace

apply-remote *FLAGS:
    colmena apply --no-substitute {{ FLAGS }}

upgrade:
    nix-update --flake terraform-providers.authentik
    nix-update --flake terraform-providers.ldap
    nix-update --flake ossfs
