#!/bin/sh

set -- hammerspoon
for pkg in "$@"; do stow -t "$HOME" "$pkg"; done
