#! /bin/sh

haxe docs/docs.hxml
haxelib run dox -i docs -o pages --title "Leather Engine Documentation"