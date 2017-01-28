# META6-bin
[![Build Status](https://travis-ci.org/gfldex/perl6-meta6-bin.svg?branch=master)](https://travis-ci.org/gfldex/perl6-meta6-bin)

Create and check META6.json files.

# SYNOPSIS

    meta6 --create --name=<project-name-here> --force
    meta6 --check
    meta6 --create-cfg-dir

# General Options

    --meta6-file=<path-to-META6.json> # defaults to ./META6.json

# Create Options

    --name
    --description
    --version # defaults to 0.0.1
    --perl # defaults to 6.c
    --author # defaults to user/name from ~/.gitconfig
    --auth # defaults to credentials/username from ~/.gitconfig

