default:
    @just --choose

apply:
    tofu apply
    tofu output --json > data.json

encrypt:
    if ! sops --decrypt terraform.tfstate.secrets | diff -q - terraform.tfstate > /dev/null; then \
        echo "Encrypting terraform.tfstate"; \
        sops --encrypt --output terraform.tfstate.secrets terraform.tfstate; \
    fi

decrypt:
    sops --decrypt --output terraform.tfstate terraform.tfstate.secrets
