#!/usr/bin/env nu

let file = $"($env.FILE_PWD)/minecraft.toml"

def main [
    --force
] {
    let options = open $file
    let users = $options.users? | default []
    let todo = if $force { $users } else { $users | where ($it.id? == null) } | get name
    let done = $todo | par-each --keep-order {|name|
        let id = (http get $"https://api.mojang.com/users/profiles/minecraft/($name)" | get id |
            str replace -r "(.{8})(.{4})(.{4})(.{4})(.{12})" "$1-$2-$3-$4-$5")
        { name: $name, new_id: $id }
    }
    let users = $users | join -l $done name
    print -n $users

    let users = $users | each {|user| {name: $user.name, id: ($user.new_id? | default $user.id?)}}
    $options | merge {users: $users} | save -f $file
}
