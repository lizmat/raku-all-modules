# FileSystem::Capacity
[![Build Status](https://travis-ci.org/ramiroencinas/perl6-FileSystem-Capacity.svg?branch=master)](https://travis-ci.org/ramiroencinas/perl6-FileSystem-Capacity)

Provides filesystem capacity information.

Currently implements:

## Filesystem volumes size and free space: ##
* GNU/Linux by df command.
* Win32 by wmic command.
* OS X by df command.

## Size of given Directory: ##
* GNU/Linux by du command.
* Win32.

## Installing the module ##

    zef update
    zef install FileSystem::Capacity

## Example Usage: ##
    use v6;
    use FileSystem::Capacity::VolumesInfo;
    use FileSystem::Capacity::DirSize;

    say "Volumes Capacity Info:";
    say "----------------------\n";

    say "Byte version:\n";

    my %vols = volumes-info();

    for %vols.sort(*.key)>>.kv -> ($location, $data) {
      say "Location: $location";
      say "Size: $data<size> bytes";
      say "Used: $data<used> bytes";
      say "Used%: $data<used%>";
      say "Free: $data<free> bytes";
      say "---";
    }

    say "----";

    say "Human version:\n";

    my %vols-human = volumes-info(:human);

    for %vols-human.sort(*.key)>>.kv -> ($location, $data) {
      say "Location: $location";
      say "Size: $data<size>";
      say "Used: $data<used>";
      say "Used%: $data<used%>";
      say "Free: $data<free>";
      say "---";
    }

    my $dir;

    given $*KERNEL {
      when /linux/ { $dir = '/bin' }
      when /win32/ { $dir = 'c:\windows' }
    }

    say "\n\nDirectory Size of $dir:";
    say "-----------------\n";

    say " Byte version: " ~ dirsize($dir) ~ " bytes";
    say "Human version: " ~ dirsize($dir, :human) ~ "\n";
