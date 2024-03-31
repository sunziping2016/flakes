#!/usr/bin/env nu
let files = http get https://download.seafile.com/api/v2.1/share-links/6e5297246c/dirents/?thumbnail_size=48&path=%2Fpro%2F | get dirent_list
let version = $files | where is_dir == false | get file_name | parse "seafile-pro-server_{version}_x86-64_Ubuntu.tar.gz" | get version | to text | ^sort -V -r | head -n 1

$version | print
