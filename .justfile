default:
    @just --choose

apply-local:
    nixos-rebuild switch --flake "git+file://$(pwd)#desktop" --use-remote-sudo --show-trace

apply *FLAGS:
    colmena apply --no-substitute {{ FLAGS }}

keyscan HOST:
    ssh-keyscan -t ed25519 {{ HOST }} 2>/dev/null | nix run p#ssh-to-age
