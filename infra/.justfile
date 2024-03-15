set positional-arguments := true

root := "01.aliyun"

default:
    @just --choose

fmt:
    tofu fmt --recursive

[no-cd]
[no-exit-message]
@_tofu *args:
    @# (sensitive dotenv) tofu {{ args }}
    env $(sops --decrypt "{{ justfile_directory() }}/tf.secrets.env" | xargs) tofu "$@"

[no-exit-message]
init *args:
    @just _tofu "-chdir=roots/{{ root }}" init "$@"

[no-exit-message]
apply *args:
    @just _tofu "-chdir=roots/{{ root }}" apply "$@"

[no-exit-message]
plan *args:
    @just _tofu "-chdir=roots/{{ root }}" plan "$@"

[no-exit-message]
tofu *args:
    @just _tofu "-chdir=roots/{{ root }}" "$@"
