set positional-arguments := true

default:
    @just --choose

fmt:
    tofu fmt --recursive

[no-cd]
[no-exit-message]
@tofu *args:
    @# (sensitive dotenv) tofu {{ args }}
    env $(sops --output-type dotenv --decrypt "{{ justfile_directory() }}/dotenv.tf.secrets.yaml" | xargs) tofu "$@"

init +args="01.aliyun":
    @just tofu "-chdir=roots/$1" init "${@:2}"

apply +args="01.aliyun":
    @just tofu "-chdir=roots/$1" apply "${@:2}"

plan +args="01.aliyun":
    @just tofu "-chdir=roots/$1" plan "${@:2}"
