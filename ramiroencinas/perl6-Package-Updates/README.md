# Package::Updates
[![Build Status](https://travis-ci.org/ramiroencinas/perl6-Package-Updates.svg?branch=master)](https://travis-ci.org/ramiroencinas/perl6-Package-Updates)

Provides a hash including package updates from the most popular package managers.

## Package managers supported: ##
* apt
* pacman
* yum
* Windows Update

## Getting the updates: ##
The updates we get through the subroutine get-updates() that returns a hash. Each element of this hash includes:

* key: Packet name.
* value <current> with the current packet version installed.
* value <new> with the new packet version available to install.

## Windows Update considerations: ##
* The updates from Windows Update is done using the powershell script get-updates.ps1. This script must be available in the same directory as the script that call the Package::Updates module.
* The returned hash only provides the name of the package (the hash key) that has a new version available.

## Permmisions considerations: ##
The script that call this module must be run by a user with administrative or root privileges.

## Installing the module: ##
    with zef:
      zef update
      zef install Package::Updates

    with Panda:
      panda update
      panda install Package::Updates

## Example Usage: ##
    use v6;
    use Package::Updates;

    my %updates = get-updates();

    for %updates.sort(*.key)>>.kv -> ($name, $data) {
      say "Packet name: $name Current: $data<current> New: $data<new>";
    }
