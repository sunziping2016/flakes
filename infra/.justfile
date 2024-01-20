default:
    @just --choose

apply:
    tofu apply
    tofu output --json nodes > nodes.json
    @just encrypt

init:
    tofu init --upgrade
    @just encrypt

fmt:
    tofu fmt --recursive

encrypt:
    if [ ! -f terraform.tfstate.secrets ] || ! sops --decrypt terraform.tfstate.secrets | diff -q - terraform.tfstate > /dev/null; then \
        echo "Encrypting terraform.tfstate"; \
        sops --encrypt --output terraform.tfstate.secrets terraform.tfstate; \
    fi

decrypt:
    sops --decrypt --output terraform.tfstate terraform.tfstate.secrets
