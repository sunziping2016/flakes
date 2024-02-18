default:
    @just --choose

apply: apply-local apply-remote

apply-local:
    nixos-rebuild switch --flake "git+file://$(pwd)#desktop" --use-remote-sudo --show-trace

apply-remote *FLAGS:
    colmena apply --no-substitute {{ FLAGS }}

keyscan HOST:
    ssh-keyscan -t ed25519 {{ HOST }} 2>/dev/null | nix run p#ssh-to-age

idm-recover-account:
    ssh root@hz0.szp15.com kanidmd recover-account admin

upgrade:
    nix-update --flake terraform-providers.authentik
    nix-update --flake terraform-providers.ldap
    nix-update --flake ossfs
